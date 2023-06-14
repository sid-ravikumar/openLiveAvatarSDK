import Foundation
import LiveKit

public class AvatarStateSynchronizer {
    private let livekitClient: LivekitClient
    private let room: Room

    public init(apiKey: String, channelName: String) {
        self.livekitClient = LivekitClient(apiKey: apiKey)
        self.room = livekitClient.join(roomName: channelName)
    }

    public func publishStateUpdate(event: String, data: Codable) throws {
        let jsonData = try JSONEncoder().encode(data)
        room.send(data: jsonData, kind: event)
    }

    public func subscribeToStateUpdates<T: Codable>(event: String, completion: @escaping (Result<T, Error>) -> Void) {
        room.onMessage(kind: event) { message in
            if let data = message.data {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(AvatarStateSynchronizerError.dataConversionFailed))
            }
        }
    }
}

public enum AvatarStateSynchronizerError: Error {
    case dataConversionFailed
}

