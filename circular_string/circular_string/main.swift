//
//  main.swift
//  circular_string
//
//  Created by madison on 11/23/20.
//
import Foundation



// accept user defined k
print("k =",terminator: " ")
if let k = readLine().flatMap(Int.init(_:)) {
    
    assert(k > 1, "BInary string must be more than 1 character long")
    // create debruijn graph (returns list of kmers)
    let kmers = create_debruijn(k: k)
    
    // traverse debruijn graph / find eulerian cycle (each edge visited only once)
    let cycle = eulerian_cycle(kmers, k: k)
    
    print("edge traversal:", cycle)
    print("circular string:", generate_circular_string(from: cycle))
}


func create_debruijn(k: Int) -> [Node] {
    // create all k-1 mers (node form)
    var kmers: [Node] = find_binary_kmers(k: k-1).compactMap { Node(prefix: $0) }
    
    // construct debruijn graph (edge labels would be all k-mers)
    // each node will have only two outgoing and two incoming
    for i in 0..<kmers.count {
        find_two_possible_postfixes(from: &kmers[i], possibilities: kmers)
    }
    
    return kmers
}

func eulerian_cycle(_ kmers: [Node], k: Int) -> [String] {
    let all_possible_edges: Set<String> = Set(find_binary_kmers(k: k).map{ $0 } )
    var seen_edges: Set<String> = []
    var edge_traversal: [String] = []
    
    while ( all_possible_edges.symmetricDifference(seen_edges).count > 0 ) {
//        print(edge_traversal)
        
        // calculate start node
        let postfixes_of_taken_edges: Set<String> = Set(seen_edges.map {$0.substring(from: $0.index($0.startIndex, offsetBy: 1))}) // where the taken edges point to
        let prefixes_of_untaken_edges: Set<String> = Set(all_possible_edges.symmetricDifference(seen_edges).map {$0.substring(to: $0.index($0.endIndex, offsetBy: -1))}) // where the untaken edges point from
        let visited_nodes_with_unused_out_edges = kmers.filter { postfixes_of_taken_edges.intersection(prefixes_of_untaken_edges).contains($0.prefix) }
        let start_node = visited_nodes_with_unused_out_edges.count > 0 ? visited_nodes_with_unused_out_edges[Int.random(in: 0..<visited_nodes_with_unused_out_edges.count)] : kmers[Int.random(in: 0..<kmers.count)]
        
        edge_traversal = update_cycle(from: start_node)
        seen_edges = Set(edge_traversal)
    }
    
    return edge_traversal
}

private func update_cycle(from start: Node) -> [String] {
    var edges_taken: Set<String> = []
    var edge_traversal: [String] = []
    var pointer = start

    while ( !(edges_taken.contains(pointer.out_edges[0]) && edges_taken.contains(pointer.out_edges[1])) ) {
        let next_edge_possibilities = Set(pointer.out_edges).subtracting(edges_taken) // only give possibility of choosing an edge that hasnt already been taken
        let edge_taken = next_edge_possibilities.randomElement()! // randomizing edge taken
        let next_node = pointer.node_from_edge(edge_taken)
        edges_taken.update(with: edge_taken)
        edge_traversal.append(edge_taken)
        pointer = next_node
    }
    return edge_traversal
}

private func find_two_possible_postfixes(from node: inout Node, possibilities kmers: [Node]) {
    let postfix_of_prefix = node.prefix.substring(from: node.prefix.index(node.prefix.startIndex, offsetBy: 1))
    for n in kmers {
        if ( postfix_of_prefix + "0" == n.prefix || postfix_of_prefix + "1" == n.prefix ) {
            node.postfixes.append(n)
        }
    }
}


private func find_binary_kmers(k: Int) -> [String] {
    if k == 1 {
        return ["0", "1"]
    }
    else {
        let so_far = find_binary_kmers(k: k-1)
        var a = so_far // copy to append 0 to
        var b = so_far // copy to append 1 to
        for i in 0..<so_far.count {
            a[i]+="0"
            b[i]+="1"
        }
        return a+b
    }
}

private func generate_circular_string(from edges: [String]) -> String {
    var result: String = ""
    for i in 0..<edges.count { // do not include last because it should be circular
        result.append(edges[i].substring(to: edges[i].index(edges[i].startIndex, offsetBy: 1))) // append the last character
    }
    return result
}
