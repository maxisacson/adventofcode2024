test_input = """\
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
"""


class Wire:
    def __init__(self, id):
        self.id = id

        self.value = None
        self.gate = None
        self.in1 = None
        self.in2 = None
        self.gate = None
        self.out = []


def run(input):
    lines = input.splitlines()
    flag = True

    wires = {}

    for line in lines:
        if len(line) == 0:
            flag = False
            continue

        if flag:
            w, v = line.split(": ")
            wire = Wire(w)
            wire.value = int(v)
            wires[w] = wire
        else:
            i1, op, i2, _, o = line.split(" ")
            if i1 not in wires:
                wire = Wire(i1)
                wire.value = None
                wires[i1] = wire
            if i2 not in wires:
                wire = Wire(i2)
                wire.value = None
                wires[i2] = wire
            if o not in wires:
                wire = Wire(o)
                wire.value = None
                wires[o] = wire

            wires[o].gate = op
            wires[o].in1 = i1
            wires[o].in2 = i2

    done = False
    while not done:
        done = True
        for _, w in wires.items():
            if w.value is not None:
                continue

            done = False

            if w.in1 is None or w.in2 is None:
                continue

            if wires[w.in1].value is None or wires[w.in2].value is None:
                continue

            v1 = wires[w.in1].value
            v2 = wires[w.in2].value

            if w.gate == "AND":
                w.value = int(v1 and v2)
            elif w.gate == "OR":
                w.value = int(v1 or v2)
            elif w.gate == "XOR":
                w.value = int(v1 != v2)

    output = 0
    for k, w in wires.items():
        if k[0] != 'z':
            continue
        i = int(k[1:])
        output |= (w.value << i)

    return output


if __name__ == "__main__":
    assert run(test_input) == 2024

    with open('day24.txt') as f:
        input = f.read()

    print(run(input))
