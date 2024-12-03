import re

test_inp = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
test_inp2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

rg = re.compile(r"mul\(\d{1,3},\d{1,3}\)")  # )
rg2 = re.compile(r"mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)")  # )


def mul(a, b):
    return a * b


def run():
    res = 0
    with open("day3.txt") as f:
        for line in f:
            matches = rg.findall(line)
            res += sum(eval(m) for m in matches)
    print(res)


def run2():
    enabled = True
    res = 0
    with open("day3.txt") as f:
        for line in f:
            matches = rg2.findall(line)
            for m in matches:
                if m == "do()":
                    enabled = True
                elif m == "don't()":
                    enabled = False
                elif enabled:
                    res += eval(m)
    print(res)


run()
run2()
