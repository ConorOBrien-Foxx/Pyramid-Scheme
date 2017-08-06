def indices(str, chr)
    (0 ... str.length).find_all { |i| str[i] == chr }
end

def unwrap(t)
    t.size == 1 ? t[0] : t
end

$TOP    = "^"
$BOTTOM = "-"
$L_SIDE = "/"
$R_SIDE = "\\"

def triangle_from(lines, ptr_inds = nil)
    raise "no triangle found" if !lines.first
    ptr_inds = ptr_inds || indices(lines.first, $TOP)
    row = ""
    ptr_inds.map { |pt|
        x1 = x2 = pt    # left and right sides
        y = 0
        data = []
        loop {
            x1 -= 1
            x2 += 1
            y += 1
            row = lines[y]
            raise "unexpected triangle end" if !row or x2 > row.size
            # are we done?
            if row[x1] != $L_SIDE
                # look for end
                if row[x2] == $R_SIDE # mismatched!
                    raise "left side too short"
                else
                    # both sides are exhausted--look for a bottom
                    # p (x1 + 1 .. x2 - 1).map { |e| row[e] }
                    # p [x1, x2, pt]
                    if (x1 + 1 .. x2 - 1).all? { |x| row[x] == $BOTTOM }
                        break
                    else
                        raise "malformed bottom"
                    end
                end
            elsif row[x2] != $R_SIDE
                # look for end
                if row[x1] == $L_SIDE # mismatched!
                    raise "right side too short"
                else
                    # both sides are exhausted--look for a bottom
                    if (x1 + 1 .. x2 - 1).all? { |x| row[x] == $BOTTOM }
                        break
                    else
                        raise "malformed bottom"
                    end
                end
            # elsif x1 == 0   # we must have found our bottom...
            end
            #todo: do for other side
            # we aren't done.
            data.push row[x1 + 1 .. x2 - 1]
        }
        op = data.join("").gsub(/\s+/, "")
        args = []
        if row[x1] == $TOP or row[x2] == $TOP
            next_inds = [x1, x2].find_all { |x| row[x] == $TOP }
            args.push triangle_from(lines[y..-1], next_inds)
        end
        unwrap [op, *args]
    }
end

$vars = {}
$UNDEF = :UNDEF

def parse(str)
    # find ^s on first line
    lns = str.lines
    triangle_from(lns)
end

# converts a string to a pyramid value
def str_to_val(str)
    # todo: expand
    if $vars.has_key? str
        $vars[str]
    elsif str == "line" or str == "stdin" or str == "readline"
        $stdin.readline
    else
        str.to_f
    end
end

def falsey(val)
    [0, [], "", $UNDEF, "\x00"].include? val
end

def truthy(val)
    !falsey val
end

class TrueClass;  def to_i; 1; end; end
class FalseClass; def to_i; 0; end; end

$outted = false

$uneval_ops = {
    "set" => -> (left, right) {
        $vars[left] = eval_chain right
        $UNDEF
    },
    # condition: left
    # body: right
    "do" => -> (left, right) {
        loop {
            eval_chain right
            break unless truthy eval_chain left
        }
        $UNDEF
    },
    # condition: left
    # body: right
    "?" => -> (left, right) {
        truthy(eval_chain left) ? eval_chain(right) : 0
    }
}

$ops = {
    "+" => -> (a, b) { a + b },
    "*" => -> (a, b) { a * b },
    "-" => -> (a, b) { a - b },
    "/" => -> (a, b) { 1.0 * a / b },
    "^" => -> (a, b) { a ** b },
    "=" => -> (a, b) { (a == b).to_i },
    "<=>" => -> (a, b) { a <=> b },
    "out" => -> (*a) { $outted = true; a.each { |e| print e }; },
    "chr" => -> (a) { a.to_i.chr },
    "arg" => -> (*a) { a.size == 1 ? ARGV[a] : a[0][a[1]] },
    "#" => -> (a) { str_to_val a },
    "" => -> (*a) { unwrap a },
    "!" => -> (a) { falsey(a).to_i },
    "[" => -> (a, b) { a },
    "]" => -> (a, b) { b },
}

def eval_chain(chain)
    if chain.is_a? String
        return str_to_val chain
    else
        op, args = chain
        if $uneval_ops.has_key? op
            return $uneval_ops[op][*args]
        end
        raise "undefined operation `#{op}`" unless $ops.has_key? op
        return sanatize $ops[op][*sanatize(args.map { |ch| eval_chain ch })]
    end
end

def sanatize(arg)
    if arg.is_a? Array
        arg.map { |e| sanatize e }
    elsif arg.is_a? Float
        arg == arg.to_i ? arg.to_i : arg
    else
        arg
    end
end

prog = File.read(ARGV[0]).gsub(/\r/, "")
parsed = parse(prog)
res = parsed.map { |ch| eval_chain ch }
res = res.is_a?(Array) && res.length == 1 ? res.pop : res
res = res.reject { |e| e == $UNDEF } if res.is_a? Array
to_print = sanatize(res)
unless $outted
    if ARGV[1] && ARGV[1][1] == "d"
        p res
    else
        puts res
    end
end