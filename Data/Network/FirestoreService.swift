import Foundation

import FirebaseFirestore

public enum FirestoreServiceError: Error {
    case invalidCollectionOrDocument
    case decodingFailed
    case firebaseError(Error)
}

public protocol FirestoreServiceProtocol {
    func fetchDocumentation<T: Decodable>(collection: String, document: String) async throws -> T
}

public class FirestoreService: FirestoreServiceProtocol {

    private let db: Firestore

    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func fetchDocumentation<T: Decodable>(
        collection: String,
        document: String
    ) async throws -> T {

        guard !collection.isEmpty, !document.isEmpty else {
            throw FirestoreServiceError.invalidCollectionOrDocument
        }

        do {
            let snapshot = try await db.collection(collection).document(document).getDocument(as: T.self)
            return snapshot
        } catch is DecodingError {
            throw FirestoreServiceError.decodingFailed
        } catch {
            throw FirestoreServiceError.firebaseError(error)
        }
    }
}
