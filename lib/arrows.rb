require_relative "arrows/version"

module A
class << self

  # Unit

  def val(v = nil)
    ->(*_) { v }
  end

  # Identity

  def id
    ->(x) { x }
  end

  # Compositions

  # pipe(:a, :b)
  # =>
  # ->(x) { x.a.b }
  #
  def pipe(*ps)
    ps = ps.map(&:to_proc)
    ->(x; v) do
      v = x
      ps.each do |p|
        v = p[v]
      end
      v
    end
  end

  # upipe(:a, :b)
  # =>
  # ->(x) { x.a.b }
  #
  def upipe(*ps)
    ps = ps.map(&:to_proc)
    ->(x; v) do
      v = x
      ps.each do |p|
        break if v.nil?
        v = p[v]
      end
      v
    end
  end

  # splat(:a, :b)
  # =>
  # ->(x) { [x.a, x.b] }
  def splat(*ps)
    ps = ps.map(&:to_proc)
    ->(x) do
      ps.map { |p| p[x] }
    end
  end

  # hash(a: :b, c: :d)
  # =>
  # ->(x) { { a: x.b, c: x.d } }
  #
  def hash(ps)
    ps = 
      ps.map do |k, p|
        [k, p.to_proc]
      end
    ->(x; h) do
      h = {}
      ps.each do |k, p|
        h[k] = p[x]
      end
      h
    end
  end

  # zip(:a, :b)
  # => 
  # ->(xs) { [xs[0].a, xs[1].b] }
  #
  def zip(*ps)
    ps = ps.map(&:to_proc)
    ->(xs) do
      xs.zip(ps)
        .map { |x, p| p[x] }
    end
  end

  # Logical

  def not(p)
    p = p.to_proc
    ->(*xs) do
      !p[*xs]
    end
  end

  def if(pred, w_true, w_false)
    pred, w_true, w_false =
      [pred, w_true, w_false].map(&:to_proc)
    ->(x) do
      pred[x] ? w_true[x] : w_false[x]
    end
  end

  def any?(*ps, &block)
    ps = ps.map(&:to_proc)
    ->(x) do
      ps.any? do |p|
        if block
          block[p[x]]
        else
          p[x]
        end
      end
    end
  end    

  def all?(*ps, &block)
    ps = ps.map(&:to_proc)
    ->(x) do
      ps.all? do |p|
        if block
          block[p[x]]
        else
          p[x]
        end
      end
    end
  end

end
end
