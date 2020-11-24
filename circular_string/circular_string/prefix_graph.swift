//
//  prefix_graph.swift
//  circular_string
//
//  Created by madison on 11/23/20.
//

class Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.prefix == rhs.prefix && lhs.postfixes == rhs.postfixes
    }
    
    
    let prefix: String
    var postfixes: [Node]
    
    var out_edges: [String] {
        get {
            let edge1 = self.prefix + "0"
            let edge2 = self.prefix + "1"
            return [edge1, edge2]
        }
    }
    
//    var postfix_of_prefix: String {
//        // substring of entire string except first char
//        get {
//            return self.prefix.substring(from: self.prefix.index(self.prefix.startIndex, offsetBy: 1))
//        }
//    }
    
    var last_character_in_prefix: String {
        get {
            return self.prefix.substring(from: self.prefix.index(self.prefix.endIndex, offsetBy: -1))
        }
    }
    
    
    init(prefix: String, point_to: [Node] = []) {
        self.prefix = prefix
        postfixes = point_to
    }
    
    func edge_between(_ node: Node) -> String {
        assert(self.postfixes.contains(node))
        
        return self.prefix + node.last_character_in_prefix
    }
    
    func node_from_edge(_ edge: String) -> Node {
        let attempted_prefix = edge.substring(from: edge.index(edge.startIndex, offsetBy: 1)) // last two of edge
        return postfixes[0].prefix == attempted_prefix ? postfixes[0] : postfixes[1]
    }
    
    
}

