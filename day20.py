test_input = """\
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"""


def find_path(map, start, end):
    dist = {}
    prev = {}
    unvisited = set()
    for i,row in enumerate(map):
        for j,c in enumerate(row):
            if c == '#':
                continue
            v = (i, j)
            dist[v] = float('inf')
            prev[v] = None
            unvisited.add(v)

    dist[start] = 0

    width = len(map[0])
    height = len(map)

    while len(unvisited) > 0:
        u = next(iter(unvisited))
        for v in unvisited:
            if dist[v] < dist[u]:
                u = v
        unvisited.remove(u)

        if u == end:
            path = []
            if prev[u] is not None or u == start:
                while u is not None:
                    path = [u] + path
                    u = prev[u]

            return path

        for (i, j) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            r, c = u
            r += i
            c += j
            if not (0 <= r < height and 0 <= c < width):
                continue

            v = (r, c)

            if v not in unvisited:
                continue

            d = dist[u] + 1
            if d < dist[v]:
                dist[v] = d
                prev[v] = u


def find_path2(map, start, end):
    unvisited = set()
    for i,row in enumerate(map):
        for j,c in enumerate(row):
            if c == '#':
                continue
            v = (i, j)
            unvisited.add(v)

    width = len(map[0])
    height = len(map)

    path = [start]
    current = start
    unvisited.remove(start)
    while current != end:
        for (i, j) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            r, c = current
            r += i
            c += j
            if not (0 <= r < height and 0 <= c < width):
                continue

            next = (r, c)

            if next not in unvisited:
                continue

            unvisited.remove(next)
            path.append(next)
            current = next

    return path


def find_cheats(map, path):
    cheats = []
    for i, row in enumerate(map):
        for j, c in enumerate(row):
            if c != '#':
                continue

            try:
                s = i - 1, j
                e = i + 1, j
                ks = path.index(s)
                ke = path.index(e)
                if ke < ks:
                    ks, ke = ke, ks
                cheats.append((ks, ke))
            except ValueError:
                pass

            try:
                s = i, j - 1
                e = i, j + 1
                ks = path.index(s)
                ke = path.index(e)
                if ke < ks:
                    ks, ke = ke, ks
                cheats.append((ks, ke))
            except ValueError:
                pass

    return cheats


def run(input, threshold):
    lines = input.splitlines()

    map = []
    for i, line in enumerate(lines):
        map.append(list(line))
        try:
            j = map[i].index('S')
            start = i, j
        except ValueError:
            pass

        try:
            j = map[i].index('E')
            end = i, j
        except ValueError:
            pass

    path = find_path2(map, start, end)
    cheats = find_cheats(map, path)

    count = 0

    for cheat in cheats:
        s, e = cheat
        saved = e - s - 2
        if saved >= threshold:
            count += 1

    return count


if __name__ == "__main__":
    assert run(test_input, 2) == 44
    assert run(test_input, 4) == 30
    assert run(test_input, 6) == 16
    assert run(test_input, 8) == 14
    assert run(test_input, 10) == 10
    assert run(test_input, 12) == 8
    assert run(test_input, 20) == 5
    assert run(test_input, 36) == 4
    assert run(test_input, 38) == 3
    assert run(test_input, 40) == 2
    assert run(test_input, 64) == 1

    with open("day20.txt") as f:
        input = f.read()

    print(run(input, 100))
