import Foundation

// Since Xcode 10.2 declarations of classes marked @objcMembers do not have the objc.name attribute.
final class ObjcMembersAttributeBuilder: SourceGraphVisitor {
    static func make(graph: SourceGraph) -> Self {
        return self.init(graph: graph, xcodebuild: inject())
    }

    private let graph: SourceGraph
    private let xcodebuild: Xcodebuild

    required init(graph: SourceGraph, xcodebuild: Xcodebuild) {
        self.graph = graph
        self.xcodebuild = xcodebuild
    }

    func visit() throws {
        guard try xcodebuild.version().isVersion(lessThan: "11.0") else { return }

        for clsDecl in graph.declarations(ofKind: .class) {
            guard clsDecl.attributes.contains("objcMembers") else { continue }

            for decl in clsDecl.declarations {
                guard decl.kind.isVariableKind || decl.kind.isFunctionKind else { continue }

                decl.attributes.insert("objc.name")
            }
        }
    }
}
