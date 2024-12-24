test_input = """\
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
"""


class Node:
    def __init__(self, id):
        self.id = id
        self.adj = []


def build_graph(input):
    graph = {}
    for line in input.splitlines():
        a, b = line.split('-')
        if a not in graph:
            graph[a] = Node(a)
        if b not in graph:
            graph[b] = Node(b)

        graph[a].adj.append(b)
        graph[b].adj.append(a)

    return graph


# def make_subgraph(graph, node):
#     unvisited = set()
#     visited = set()
#     visited.add(node.id)
#     for n in node.adj:
#         unvisited.add(n)
#
#     while len(unvisited) > 0:
#         n = unvisited.pop()
#         visited.add(n)
#
#         for m in graph[n].adj:
#             if m not in visited:
#                 unvisited.add(m)
#
#     return list(sorted(visited))

def find_subgraph(graph, node):
    if len(node.adj) < 2:
        return []

    subgraphs = []
    for i in range(len(node.adj)-1):
        for j in range(i+1, len(node.adj)):
            n1 = node.adj[i]
            n2 = node.adj[j]

            if n1 in graph[n2].adj:
                subgraphs.append(tuple(sorted([node.id, n1, n2])))
    return subgraphs


def find_subgraph2(graph, node):
    if len(node.adj) < 2:
        return []

    subgraphs = []
    for i in range(len(node.adj)-1):
        for j in range(i+1, len(node.adj)):
            n1 = node.adj[i]
            n2 = node.adj[j]

            if n1 in graph[n2].adj:
                subgraphs.append(tuple(sorted([node.id, n1, n2])))
    return subgraphs


def run(input):
    graph = build_graph(input)

    subgraphs = set()
    for _, v, in graph.items():
        subgraph = find_subgraph(graph, v)
        for sg in subgraph:
            subgraphs.add(sg)

    subgraphs = list(sorted(subgraphs))

    count = 0
    for sg in subgraphs:
        if any(map(lambda n: n[0] == 't', sg)):
            count += 1
    print(count)


def run2(input):
    graph = build_graph(input)

    subgraphs = set()
    for _, v, in graph.items():
        find_subgraph2(graph, v)
        # subgraph = v.adj + [v.id]
        # subgraphs.add(",".join(list(sorted(subgraph))))

    print(subgraphs)


if __name__ == "__main__":
    run(test_input)
    # run2(test_input)

    with open('day23.txt') as f:
        input = f.read()

    run(input)
