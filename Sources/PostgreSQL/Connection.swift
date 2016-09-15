#if os(Linux)
    import CPostgreSQLLinux
#else
    import CPostgreSQLMac
#endif

import Core

public final class Connection {
    private(set) var pointer: OpaquePointer!
    
    public var connected: Bool {
        if let pointer = pointer, PQstatus(pointer) == CONNECTION_OK {
            return true
        }
        return false
    }
    
    public init(host: String = "localhost", port: String = "5432", dbname: String, user: String, password: String) throws {

        self.pointer = PQconnectdb("host='\(host)' port='\(port)' dbname='\(dbname)' user='\(user)' password='\(password)'")
        if !self.connected {
            throw DatabaseError.cannotEstablishConnection
        }
    }

    public func reset() throws {
        guard self.connected else {
            throw DatabaseError.cannotEstablishConnection
        }
        
        PQreset(self.pointer)
    }
    
    public func close() throws {
        guard self.connected else {
            throw DatabaseError.cannotEstablishConnection
        }
        
        PQfinish(self.pointer)
    }
    
    deinit {
        try? close()
    }
}
