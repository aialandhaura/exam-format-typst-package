// a solid letter followed by n light-grey copies to trace over
#let trace(c, n: 3) = box({
  text(size: 28pt, weight: "bold")[#c]
  h(0.5em)
  for _ in range(n) {
    text(size: 28pt, fill: luma(190))[#c]
    h(0.4em)
  }
})

#let dot = circle(radius: 2.5pt, fill: black)

// match-the-columns layout: left items, dots, gap, dots, right items
#let match-rows(left, right) = grid(
  columns: (3.5cm, 0.5cm, 3cm, 0.5cm, 3.5cm),
  row-gutter: 1.2em,
  align: horizon,
  ..left.zip(right).map(((l, r)) => (
    l, align(center, dot), [], align(center, dot), align(center, r),
  )).flatten(),
)

#let kgline(w: 3cm) = box(width: w, line(length: 100%, stroke: 0.5pt))
#let pic(e) = text(size: 28pt, e)
#let word(x) = text(size: 16pt, x)
#let letter(x) = text(size: 22pt, x)

// "A _ C _ E" -> letters with empty boxes where "_" is
#let missing(s) = text(size: 20pt, s.split(" ").map(x =>
  if x == "_" {
    box(width: 1.1em, height: 1.3em, stroke: 0.6pt, radius: 2pt, baseline: 0.25em)
  } else { x }
).join(h(0.6em)))

// picture -> options to circle
#let choose(p, ..opts) = {
  pic(p)
  h(1em)
  sym.arrow.r
  h(1em)
  opts.pos().map(o => text(size: 20pt, o)).join(h(1.5em))
}

// picture + word with a missing vowel, e.g. c_t
#let vowel(p, pre, post) = {
  pic(p)
  h(1em)
  text(size: 20pt)[#pre #box(width: 1cm, line(length: 100%, stroke: 0.5pt)) #post]
}

// picture + blank line to write its name
#let name-it(p) = {
  pic(p)
  h(1em)
  kgline(w: 3.5cm)
}