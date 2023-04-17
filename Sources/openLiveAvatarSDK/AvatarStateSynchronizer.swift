import Foundation
import Ably

public class AvatarStateSynchronizer {
    private let ablyRealtime: ARTRealtime
    private let channel: ARTRealtimeChannel

    public init(apiKey: String, channelName: String) {
        self.ablyRealtime = ARTRealtime(key: apiKey)
        self.channel = ablyRealtime.channels.get(channelName)
    }

    public func publishStateUpdate(event: String, data: Codable) throws {
        let jsonData = try JSONEncoder().encode(data)
        channel.publish(event, data: jsonData)
    }

    public func subscribeToStateUpdates<T: Codable>(event: String, completion: @escaping (Result<T, Error>) -> Void) {
        channel.subscribe(event) { message in
            if let data = message.data as? Data {
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
