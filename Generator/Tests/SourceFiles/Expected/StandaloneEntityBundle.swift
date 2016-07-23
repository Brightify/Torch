import Torch

public struct UserProjectEntityBundle: Torch.TorchEntityBundle {
    public let entityTypes: [Torch.TorchEntity.Type] = [
            Data.self,
            Data2.self,
        ]

    public init() { }
}
