
from pprint import PrettyPrinter

pp = PrettyPrinter()

test_input = """\
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""


def check_line(line, rules):
    forbidden = set()
    n = line.split(',')
    middle = n[len(n)//2]
    for b in n:
        if b in forbidden:
            return False, middle
        if b in rules:
            a = rules[b]
            forbidden = forbidden.union(set(a))
    return True, middle


def run():
    rules = {}
    read_rules = True
    sum = 0
    with open("day5.txt") as f:
        for line in f:
            if read_rules:
                if len(line) <= 1:
                    read_rules = False
                    continue
                a, b = line.strip().split('|')
                if b in rules:
                    rules[b].append(a)
                else:
                    rules[b] = [a]
            else:
                line = line.strip()
                if len(line) == 0:
                    break
                ok, p = check_line(line, rules)
                if ok:
                    sum += int(p)

    print(sum)


def fix_line(line, rules):
    return 0
    forbidden = set()
    n = line.split(',')
    middle = n[len(n)//2]
    for i,b in enumerate(n):
        if b in forbidden:
            return False, middle
        if b in rules:
            a = rules[b]
            forbidden = forbidden.union(set(a))
    return True, middle


def run2():
    rules = {}
    read_rules = True
    sum = 0
    with open("day5.txt") as f:
        #     for line in f:
        for line in test_input.split('\n'):
            if read_rules:
                if len(line) <= 1:
                    read_rules = False
                    continue
                a, b = line.strip().split('|')
                if b in rules:
                    rules[b].append(a)
                else:
                    rules[b] = [a]
            else:
                line = line.strip()
                if len(line) == 0:
                    break
                ok, _ = check_line(line, rules)
                if not ok:
                    p = fix_line(line, rules)
                    sum += p

    print(sum)


# run()
run2()
