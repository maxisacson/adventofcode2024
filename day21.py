test_input = """\
029A
980A
179A
456A
379A
"""


def get_numpad_pos(c):
    nums = [
        ['7', '8', '9'],
        ['4', '5', '6'],
        ['1', '2', '3'],
        [' ', '0', 'A'],
    ]

    rows = len(nums)
    for i, row in enumerate(nums):
        try:
            x = row.index(c)
            y = rows - i - 1
            return y, x
        except ValueError:
            pass


def gen_numpad_moves_(start, target):
    y0, x0 = get_numpad_pos(start)
    y1, x1 = get_numpad_pos(target)

    dy = y1 - y0
    dx = x1 - x0

    lr = '<' if dx < 0 else '>'
    du = 'v' if dy < 0 else '^'

    if x0 == 0 and y1 == 0:
        return lr * abs(dx) + du * abs(dy) + 'A'
    elif y0 == 0 and x1 == 0:
        return du * abs(dy) + lr * abs(dx) + 'A'
    else:
        if dx < 0:
            return lr * abs(dx) + du * abs(dy) + 'A'
        else:
            return du * abs(dy) + lr * abs(dx) + 'A'


def gen_numpad_moves(seq):
    current = 'A'
    moves = []
    for c in seq:
        moves += gen_numpad_moves_(current, c)
        current = c

    return moves


def get_dirpad_pos(c):
    dirs = [
        [' ', '^', 'A'],
        ['<', 'v', '>'],
    ]

    rows = len(dirs)
    for i, row in enumerate(dirs):
        try:
            x = row.index(c)
            y = rows - i - 1
            return y, x
        except ValueError:
            pass


def gen_dirpad_moves_(start, target):
    y0, x0 = get_dirpad_pos(start)
    y1, x1 = get_dirpad_pos(target)

    dy = y1 - y0
    dx = x1 - x0

    lr = '<' if dx < 0 else '>'
    du = 'v' if dy < 0 else '^'

    if x0 == 0 and y1 == 1:
        return lr * abs(dx) + du * abs(dy) + 'A'
    elif y0 == 1 and x1 == 0:
        return du * abs(dy) + lr * abs(dx) + 'A'
    else:
        if dx < 0:
            return lr * abs(dx) + du * abs(dy) + 'A'
        else:
            return du * abs(dy) + lr * abs(dx) + 'A'


def gen_dirpad_moves(seq):
    current = 'A'
    moves = []
    for c in seq:
        moves += gen_dirpad_moves_(current, c)
        current = c

    return moves


def gen_moves(code):
    moves = gen_numpad_moves(code)
    moves = gen_dirpad_moves(moves)
    moves = gen_dirpad_moves(moves)
    return moves


def run(input):
    sum = 0
    for code in input.splitlines():
        moves = gen_moves(code)
        sum += len(moves) * int(code[:-1])

    return sum


if __name__ == "__main__":
    print(run(test_input))

    with open('day21.txt') as f:
        input = f.read()

    print(run(input))
