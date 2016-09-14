#if os(Linux)
    import CPostgreSQLLinux
#else
    import CPostgreSQLMac
#endif

public enum DatabaseError: Error {
    case cannotEstablishConnection
    case indexOutOfRange
    case columnNotFound
    case invalidSQL(message: String)
    case noQuery
    case noResults
}

public class Database {
    internal(set) var host: String = ""
    internal(set) var port: String = ""
    internal(set) var dbname: String = ""
    internal(set) var user: String = ""
    internal(set) var password: String = ""
    
    internal var connection: Connection!
    
    public init() {
        
    }
    
    public init(host: String = "localhost", port: String = "5432", dbname: String, user: String, password: String) throws {
        self.host = host 
        self.port = port 
        self.dbname = dbname
        self.user = user 
        self.password = password
        self.connection = try makeConnection()
    }
    
    @discardableResult
    public func execute(_ query: String, _ values: [Node]? = [], on connection: Connection? = nil) throws -> [[String: Node]] {
        if let connection = connection {
             self.connection = connection
        } else if self.connection == nil {
            self.connection = try makeConnection()
        }
        
        guard !query.isEmpty else {
            throw DatabaseError.noQuery
        }
        
        let res: OpaquePointer
        
        if let values = values, values.count > 0 {
            let paramsValues = bind(values)
            res = PQexecParams(self.connection.pointer, query, Int32(values.count), nil, paramsValues, nil, nil, Int32(0))
            defer { paramsValues.deinitialize() }
        } else {
            res = PQexec(self.connection.pointer, query)
        }
        
        defer { PQclear(res) }
        switch Status(result: res) {
        case .nonFatalError:
            throw DatabaseError.invalidSQL(message: String(cString: PQresultErrorMessage(res)) )
        case .fatalError:
            throw DatabaseError.invalidSQL(message: String(cString: PQresultErrorMessage(res)) )
        case .unknown:
            throw DatabaseError.invalidSQL(message: String(cString: PQresultErrorMessage(res)) )
        case .tuplesOk:
            return Result(resultPointer: res).dictionary
        default:
            break
        }
        return []
    }
    
    func bind(_ values: [Node]) -> UnsafeMutablePointer<UnsafePointer<Int8>?> {

        let bindedValues = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: values.count)

        var bytes = [[UInt8]]()
        for i in 0..<values.count {
            if values[i].isNull {
                bytes.append([0])   
            } else {
                bytes.append([UInt8](values[i].utf8) + [0])
            }
            
            bindedValues[i] = UnsafePointer<Int8>(OpaquePointer(bytes.last!))
        }
        return bindedValues
    }
    
    @discardableResult
    public func makeConnection() throws -> Connection {
        return try Connection(host: self.host, port: self.port, dbname: self.dbname, user: self.user, password: self.password)
    }
}
