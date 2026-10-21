#let OR = align(center)[*OR*]
#let higher-classes = (
  "IX", "ix", "9", "9th", "X", "x", "10", "10th",
  "XI", "xi", "11", "11th", "XII", "xii", "12", "12th",
)

// ---- Language strings ----
#let strings = (
  en: (
    academy: "Aaisha International Academy",
    exam: (HY: "Half-Yearly Examination", AN: "Annual Examination"),
    subject: "Subject",
    class: "Class",
    duration: "Duration",
    hours: "3 hours",
    max: "Maximum Marks",
    q: "Q"

  ),
  hi: (
    academy: "आईशा इन्टरनेशन्ल एकेड़मी",
    exam: (HY: "अर्धवार्षिक परीक्षा", AN: "वार्षिक परीक्षा"),
    subject: "विषय",
    class: "कक्षा",
    duration: "अवधि",
    hours: "3 घंटे",
    max: "पूर्णांक",
    q: "प्र०",
  ),
)
// Must be called inside `context`
#let S() = strings.at(text.lang, default: strings.en)
#let t(key) = context S().at(key)

// "HY", 26  ->  "Half-Yearly Examination 2026-2027" (in the active language)
#let session-title(exam, yy) = context {
  let y = 2000 + int(yy)
  [#S().exam.at(upper(exam)) #(str(y) + "-" + str(y + 1))]
}

#let marks = counter("marks")
#let qno = counter("qno")

#let question(m, body) = {
  marks.update(n => n + m)
  qno.step()
  block(width: 100%, context {
    // marks box first, so it stays on the page where the question starts
    if m != 0 {
      place(
        top + left,
        dx: -1cm,
        dy: -2pt,
        rect(inset: 2.5pt, radius: 2pt, stroke: 0.4pt)[#m],
      )
    }
    grid(
      columns: (1.4cm, 1fr),
      [*#S().q#qno.display().*], body,
    )
  })
}

// exam: "HY" or "AN"
// yy:   last two digits of the first year of the session, e.g. 26 -> 2026-2027
#let header(exam, yy, subject, class, duration: auto) = [
  #align(center)[
    #if class not in higher-classes [
      #smallcaps()[#text(size: 20pt)[*#t("academy")*]] #linebreak()
    ]
    #if class in higher-classes [
      #text(size: 20pt)[#smallcaps()[*#session-title(exam, yy)*]]
      #linebreak()
    ] else [
      #text(size: 14pt)[#smallcaps()[#session-title(exam, yy)]]
      #linebreak()
    ]
    #v(4pt)
    #upper()[#t("subject"): *#subject*]\
    #grid(
      columns: (auto, 1fr, auto),
      [#t("duration"): #if duration == auto { t("hours") } else { duration }],
      [#upper()[#t("class"): *#class*]],
      [#t("max"): #context marks.final().first()],
    )
    #line(length: 100%)
  ]
]



// for match the columns, pair function
#let pair(left, right, left-num: "(1)", right-num: "(i)") = grid(
  columns: (1cm, 1fr, 1cm, auto), row-gutter: 0.6em,
  ..left.zip(right).enumerate().map(((i, (l, r))) => (
    [#numbering(left-num, i + 1)], [#l],
    [#numbering(right-num, i + 1)],[#r],
  )).flatten()
)

// helpers local to this paper
#let opts(..a) = {
  let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i")
  stack(dir: ltr, spacing: 2.5em, ..a.pos().enumerate().map(((i, x)) => [(#letters.at(i))~#x]))
}

#let blank(w: 6em) = box(width: w, stroke: (bottom: 0.5pt))

// `set` rules don't carry across an import, so they live here.
// Use in the paper with:  #show: setup
#let setup(doc) = {
  set text(font: ("New Computer Modern", "Tiro Devanagari Hindi"))
  set list(indent: 10pt)
  set enum(indent: 10pt, numbering: "i. ")
  set par(justify: true)
  doc
}

#let poetry(body) = [
  #set par(spacing: 24pt, justify: true)
  #set align(center)
 
  #emph(body)
  #v(12pt) 
]

#let extract(body)= rect(stroke: 0pt, radius: 2pt, body)
#let sec(t) = align(center)[#text(size: 1.4em, strong(t))]
#let words(cols, ans: false, ..xs) = grid(
  columns: (1fr,) * cols, row-gutter: 0.9em,
  ..xs.pos().enumerate(start: 1).map(((i, x)) => [#(i). #x #if ans [#blank(w: 2cm)]]),
)

// English (a) (b) (c) list
#let abc(..xs) = enum(numbering: "(a)", spacing: 1em, ..xs.pos())
#let tk(x) = [#x (#h(1em))]


//----------MATH RELATED FUNCTIONS ONLY ------------//

// ---------- Vertical arithmetic: kgadd, kgminus, kgmultiply ----------

#let _kg-cw = 1.1em   // width of one digit column
#let _kg-ow = 1.3em   // width of the operator column
#let _kg-lh = 1.6em   // height of one blank answer line

// strs   : numbers as strings, top to bottom
// op     : operator shown before the last number
// ncols  : number of digit columns (rules are as wide as these columns)
// circ   : how many carry circles (placed above tens, hundreds, ...)
// carry  : true -> draw empty carry circles above the first number
// gap    : number of blank lines between the two rules
#let _kg-col(strs, op, ncols, circ, carry, gap) = {
  let n = strs.len()
  let cells = ()

  if carry and circ > 0 {
    cells.push([])
    for i in range(ncols) {
      let p = ncols - 1 - i          // 0 = units, 1 = tens, ...
      if p >= 1 and p <= circ {
        cells.push(circle(radius: 0.45em, stroke: 0.5pt))
      } else {
        cells.push([])
      }
    }
  }

  for (r, s) in strs.enumerate() {
    cells.push(if r == n - 1 { align(left)[#op] } else [])
    for i in range(ncols) {
      let p = ncols - 1 - i
      cells.push(if p < s.len() { s.at(s.len() - 1 - p) } else [])
    }
  }

  box(
    width: _kg-ow + ncols * _kg-cw,
    stack(
      dir: ttb,
      spacing: 0pt,
      grid(
        columns: (_kg-ow,) + (_kg-cw,) * ncols,
        row-gutter: 0.4em,
        align: center + horizon,
        ..cells,
      ),
      v(0.3em),
      line(length: 100%, stroke: 0.6pt),
      v(gap * _kg-lh),
      line(length: 100%, stroke: 0.6pt),
    ),
  )
}

// kgadd(1234, 5678, 912)
#let kgadd(..nums, carry: false, cols: auto) = {
  let strs = nums.pos().map(str)
  assert(strs.len() >= 2, message: "kgadd needs at least two numbers")
  let m = calc.max(..strs.map(s => s.len()))
  let w = if cols == auto { m + 1 } else { cols }   // +1 column for overflow
  _kg-col(strs, sym.plus, w, m - 1, carry, 1)
}

// kgminus(5678, 3456)
#let kgminus(..nums, carry: false, cols: auto) = {
  let strs = nums.pos().map(str)
  assert(strs.len() >= 2, message: "kgminus needs at least two numbers")
  let m = calc.max(..strs.map(s => s.len()))
  let w = if cols == auto { m } else { cols }
  _kg-col(strs, sym.minus, w, m - 1, carry, 1)
}

// kgmultiply(356, 72)  -> blank lines = number of digits in the last number
#let kgmultiply(..nums, carry: false, cols: auto) = {
  let strs = nums.pos().map(str)
  assert(strs.len() >= 2, message: "kgmultiply needs at least two numbers")
  // a product has at most (sum of digit counts) digits
  let w = if cols == auto { strs.map(s => s.len()).sum() } else { cols }
  _kg-col(strs, sym.times, w, strs.first().len() - 1, carry, strs.last().len())
}

//----------END of MATH RELATED FUNCTIONS ONLY ------------//

