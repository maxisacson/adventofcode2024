test_input = """\
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"""


class Map:
    def __init__(self, data):
        self.data = [[c for c in line] for line in data]
        self.rows = len(data)
        self.cols = len(data[0])

    def is_valid(self, row, col):
        return 0 <= row < self.rows and 0 <= col < self.cols

    def get(self, row, col):
        if not self.is_valid(row, col):
            return ""

        return self.data[row][col]

    def set(self, row, col, v):
        if not self.is_valid(row, col):
            return

        self.data[row][col] = v

    def print(self):
        for row in self.data:
            print("".join(row))

    def sum_gps(self):
        sum = 0
        for i, row in enumerate(self.data):
            for j, v in enumerate(row):
                if v == 'O':
                    sum += 100 * i + j
        return sum


class Map2:
    def __init__(self, data):
        d = {
            '#': '##',
            'O': '[]',
            '.': '..',
            '@': '@.',
        }
        self.data = []
        for line in data:
            row = []
            for v in line:
                for c in d[v]:
                    row.append(c)
            self.data.append(row)

        self.rows = len(self.data)
        self.cols = len(self.data[0])

    def is_valid(self, row, col):
        return 0 <= row < self.rows and 0 <= col < self.cols

    def get(self, row, col):
        if not self.is_valid(row, col):
            return ""

        return self.data[row][col]

    def set(self, row, col, v):
        if not self.is_valid(row, col):
            return

        self.data[row][col] = v

    def print(self):
        for row in self.data:
            print("".join(row))

    def sum_gps(self):
        sum = 0
        for i, row in enumerate(self.data):
            for j, v in enumerate(row):
                if v == '[':  # ]
                    sum += 100 * i + j
        return sum


class Robot:
    def __init__(self, row, col):
        self.row = row
        self.col = col

    def move(self, m, map):
        if m == '<':
            dir = (0, -1)
        elif m == 'v':
            dir = (1, 0)
        elif m == '^':
            dir = (-1, 0)
        elif m == '>':
            dir = (0, 1)
        else:
            assert False

        row = self.row + dir[0]
        col = self.col + dir[1]

        if map.get(row, col) == ".":
            self.move_to(row, col, map)
            return

        if map.get(row, col) == "O":
            if self.push(row, col, dir, map):
                self.move_to(row, col, map)

    def move_to(self, row, col, map):
        map.set(self.row, self.col, '.')
        map.set(row, col, '@')
        self.row = row
        self.col = col

    def push(self, row, col, dir, map):
        next = (row + dir[0], col + dir[1])
        if map.get(*next) == ".":
            map.set(row, col, '.')
            map.set(*next, 'O')
            return True
        if map.get(*next) == "O":
            if self.push(*next, dir, map):
                map.set(row, col, '.')
                map.set(*next, 'O')
                return True
            else:
                return False
        if map.get(*next) == "#":
            return False


class Robot2:
    def __init__(self, row, col):
        self.row = row
        self.col = col

    def move(self, m, map):
        if m == '<':
            dir = (0, -1)
        elif m == 'v':
            dir = (1, 0)
        elif m == '^':
            dir = (-1, 0)
        elif m == '>':
            dir = (0, 1)
        else:
            assert False

        row = self.row + dir[0]
        col = self.col + dir[1]

        if map.get(row, col) == ".":
            self.move_to(row, col, map)
            return

        if map.get(row, col) in ["[", "]"]:
            if self.push(row, col, dir, map):
                self.move_to(row, col, map)

    def move_to(self, row, col, map):
        map.set(self.row, self.col, '.')
        map.set(row, col, '@')
        self.row = row
        self.col = col

    def push1(self, row, col, dir, map):
        next = (row + dir[0], col + dir[1])
        if map.get(*next) == ".":
            v = map.get(row, col)
            map.set(row, col, '.')
            map.set(*next, v)
            return True
        if map.get(*next) in ["[", "]"]:
            if self.push(*next, dir, map):
                v = map.get(row, col)
                map.set(row, col, '.')
                map.set(*next, v)
                return True
            else:
                return False
        if map.get(*next) == "#":
            return False

    def can_push2(self, row, col, dir, map):
        v = map.get(row, col)
        next = (row + dir[0], col + dir[1])

        if v == "[":  # ]
            next2 = (next[0], next[1] + 1)
        elif v == "]":
            next2 = (next[0], next[1] - 1)

        if map.get(*next) == "#" or map.get(*next2) == "#":
            return False

        if map.get(*next) == "." and map.get(*next2) == ".":
            return True

        next_ok = True
        if map.get(*next) in ("[", "]"):
            next_ok = self.can_push2(*next, dir, map)

        next2_ok = True
        if map.get(*next2) in ("[", "]"):
            next2_ok = self.can_push2(*next2, dir, map)

        return next_ok and next2_ok

    def push(self, row, col, dir, map):
        if dir[0] == 0:
            return self.push1(row, col, dir, map)

        if not self.can_push2(row, col, dir, map):
            return False

        return self.push2(row, col, dir, map)

    def push2(self, row, col, dir, map):
        v = map.get(row, col)
        next = (row + dir[0], col + dir[1])

        if v == "[":  # ]
            col2 = col + 1
            next2 = (next[0], next[1] + 1)
        elif v == "]":
            col2 = col - 1
            next2 = (next[0], next[1] - 1)

        v2 = map.get(row, col2)

        if map.get(*next) in ["[", "]"]:
            self.push2(*next, dir, map)

        if map.get(*next2) in ["[", "]"]:
            self.push2(*next2, dir, map)

        map.set(row, col, '.')
        map.set(row, col2, '.')
        map.set(*next, v)
        map.set(*next2, v2)

        return True


def run(input):
    parse_moves = False
    moves = ""
    map_data = []
    row = -1
    col = -1
    for i, line in enumerate(input.splitlines()):
        if len(line) == 0:
            parse_moves = True
            continue

        if parse_moves:
            moves += line
        else:
            if col == -1:
                col = line.find("@")
                row = i
            map_data.append(line)

    map = Map(map_data)
    robot = Robot(row, col)

    for move in moves:
        robot.move(move, map)

    return map.sum_gps()


def run2(input):
    parse_moves = False
    moves = ""
    map_data = []
    for line in input.splitlines():
        if len(line) == 0:
            parse_moves = True
            continue

        if parse_moves:
            moves += line
        else:
            map_data.append(line)

    map = Map2(map_data)

    for i, row in enumerate(map.data):
        for j, c in enumerate(row):
            if c == '@':
                robot = Robot2(i, j)

    for move in moves:
        robot.move(move, map)

    return map.sum_gps()


if __name__ == "__main__":
    assert run(test_input) == 10092
    assert run2(test_input) == 9021

    with open('day15.txt') as f:
        input = f.read()

    print(run(input))
    print(run2(input))
