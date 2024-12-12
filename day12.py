
test_input = """\
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""


class Bounds:
    def __init__(self, grid):
        rows = len(grid)
        cols = len(grid[0])
        self.rows = rows
        self.cols = cols

    def inside(self, i, j):
        return 0 <= i < self.rows and 0 <= j < self.cols


def fill(grid, row, col, visited):
    if visited[row][col]:
        return []

    kind = grid[row][col]
    bounds = Bounds(grid)

    nbrs = [(row, col + 1),
            (row + 1, col),
            (row, col - 1),
            (row - 1, col)]

    region = [(row, col)]
    visited[row][col] = True

    for i, j in nbrs:
        if not bounds.inside(i, j):
            continue

        if kind == grid[i][j] and not visited[i][j]:
            region += fill(grid, i, j, visited)

    return region


def on_edge(grid, row, col):
    bounds = Bounds(grid)

    nbrs = [(row, col + 1),
            (row + 1, col),
            (row, col - 1),
            (row - 1, col)]

    kind = grid[row][col]
    for p, q in nbrs:
        if not bounds.inside(p, q) or grid[p][q] != kind:
            return True

    return False


def perimiter(grid, region):
    i0, j0 = region[0]
    kind = grid[i0][j0]
    bounds = Bounds(grid)

    peri = 0
    for i, j in region:
        nbrs = [(i, j + 1),
                (i + 1, j),
                (i, j - 1),
                (i - 1, j)]
        for p, q in nbrs:
            if not bounds.inside(p, q) or grid[p][q] != kind:
                peri += 1

    return peri


def top_left(region):
    top, left = region[0]
    for i, j in region:
        top = min(top, i)
        left = min(left, j)
    return top, left


def bottom_right(region):
    bottom, right = region[0]
    for i, j in region:
        bottom = max(bottom, i)
        right = max(right, j)
    return bottom, right


def get_contig_row(row, grid, region):
    c = 0
    length = len(grid[row])
    while c < length and grid[row][c] not in region:
        c += 1

    assert c < length

    bounds = Bounds(grid)

    same = False
    while c < length:
        if grid[row][c] in region and (not bounds.inside(row-1, c) or grid[row-1][c] not in region):
            if not same:
               same = True
        else:
            same = False
        c += 1


def sides(grid, region):
    top, left = top_left(region)
    bottom, right = bottom_right(region)

    rs = set(region)
    # for row in range(top, bottom+1):
    #     for col in range(left, right+1):
    #         if (row, col) not in rs:
    #             continue
    for row in range(top, bottom+1):
        r = get_contig_row(row, grid, rs)


def run(input):
    grid = input.splitlines()

    rows = len(grid)
    cols = len(grid[0])

    visited = [[False] * cols for _ in range(rows)]
    regions = []
    for i in range(rows):
        for j in range(cols):
            reg = fill(grid, i, j, visited)
            if len(reg) > 0:
                regions.append(reg)

    total = 0
    for k, region in enumerate(regions):
        area = len(region)
        peri = perimiter(grid, region)
        price = area * peri
        total += price

    print(total)


def run2(input):
    print(input)
    grid = input.splitlines()

    rows = len(grid)
    cols = len(grid[0])

    visited = [[False] * cols for _ in range(rows)]

    regions = []

    for i in range(rows):
        for j in range(cols):
            reg = fill(grid, i, j, visited)
            if len(reg) > 0:
                regions.append(reg)

    total = 0
    for k, region in enumerate(regions):
        area = len(region)
        s = sides(grid, region)
        price = area * s
        print(f"{area} * {s} = {price}")
        total += price

    print(total)


if __name__ == "__main__":
    # run(test_input)
    # with open("day12.txt") as f:
    #     input = f.read()
    # run(input)

    run2(test_input)
