test_input = """\
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
"""


def run(input):
    lines = input.splitlines()

    key = [0]*5
    lock = [0]*5

    keys = []
    locks = []

    j = 0
    parse = None
    for line in lines:
        if line == "":
            parse = None
            continue
        elif parse == "key":
            if j == 5:
                keys.append(key)
                key = [0]*5
                j = 0
                continue
            for i,c in enumerate(line):
                if c == '#':
                    key[i] += 1;
            j += 1
        elif parse == "lock":
            if j == 5:
                locks.append(lock)
                lock = [0]*5
                j = 0
                continue
            for i,c in enumerate(line):
                if c == '#':
                    lock[i] += 1;
            j += 1
        elif line == "#####":
            parse = "lock"
            continue
        elif line == ".....":
            parse = "key"
            continue
        else:
            assert False


    combos = set()
    count = 0
    for lock in locks:
        for key in keys:
            if all(map(lambda x: x <= 5, (k + l for k,l in zip(key, lock)))):
                count += 1

    return count


if __name__ == "__main__":
    assert run(test_input) == 3

    with open("day25.txt") as f:
        input = f.read()

    print(run(input))
