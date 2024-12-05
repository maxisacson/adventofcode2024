
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
    # pp.pprint(rules)
    indices = {}
    n = line.split(',')
    bad = [False] * len(n)

    forbidden = set()
    for i,b in enumerate(n):
        indices[b] = i
        if b in forbidden:
            bad[i] = True
        if b in rules:
            a = rules[b]
            forbidden = forbidden.union(set(a))

    if not any(bad):
        return n[len(n)//2]

    # print(line)
    copy = n.copy()
    for i,a in enumerate(n):
        if not bad[i]:
            continue

        for j,b in enumerate(n):
            if a == b:
                break
            if b not in rules:
                continue
            rule = rules[b]
            if a in rule:
                # print(j, a, b)
                copy.insert(j,a)
                # print(",".join(copy))
                copy.pop(i+1)
                # print(",".join(copy))
                # print()
                return fix_line(",".join(copy), rules)


def run2():
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
                ok, _ = check_line(line, rules)
                if not ok:
                    p = fix_line(line, rules)
                    sum += int(p)

    print(sum)


run()
run2()
