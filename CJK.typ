#import "@preview/booktabs:0.0.4": *
#import "@preview/easy-pinyin:0.1.0": pinyin, zhuyin
#import "@preview/tiaoma:0.4.0": qrcode
#show: booktabs-default-table-style

#let section = counter("section")
#let section-name = ("1": "Chinese", "2": "Japanese", "3": "Korean")
#set page(
  paper: "us-letter",
  margin: 1cm,
  flipped: true,
  header: context {
    set text(1em)
    let page-num = here().page()
    // 该页是否已有 H1(已有则标题本身就在页面上,不再重复)
    let has-h1 = page-num in query(heading.where(level: 1)).map(h => h.location().page())
    let name = section-name.at(str(section.at(here()).first()), default: "")
    // hide 占位,保证 header 高度不变、不引起重新分页
    if has-h1 [
      #h(1fr)
      #counter(page).display(
        "1 / 1",
        both: true,
      )
    ] else [
      #h(1fr)
      #name
      #h(1fr)
      #counter(page).display(
        "1 / 1",
        both: true,
      )
    ]
  },
  footer: place(bottom + left, dx: -1em, dy: -4em, {
    set align(center)
    box(width: 6em)[
      #text(size: 0.8em)[Get a copy of this]\
      #box(
        width: 6em,
        height: 6em,
        align(center + horizon, qrcode(
          "https://teddyhuang.is-a.dev/CJK/CJK.pdf",
          width: 6em,
          height: 6em,
        )),
      )
    ]
  }),
)
#set text(font: ("Maple Mono NF", "D2Coding ligature"))
#set align(center)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  section.step()
  it
}

#let zy = zhuyin.with(delimiter: "|", spacing: 0.1em)
#let invalid = box(height: 1em, width: 1em, fill: gray)

#let blk(title, tbl) = block(breakable: false)[
  #title

  #tbl
]

= Chinese #zy[拼|音][pi1n|yi1n]

#let pinyin-initials = (
  "",
  "b",
  "p",
  "m",
  "f",
  "d",
  "t",
  "n",
  "l",
  "g",
  "k",
  "h",
  "j",
  "q",
  "x",
  "zh",
  "ch",
  "sh",
  "r",
  "z",
  "c",
  "s",
)
#let pinyin-simple-vowels = (
  "a",
  "o",
  "e",
  "i",
  "u",
  "ü",
)
#let pinyin-compound-vowels = (
  "ai",
  "ao",
  "ou",
  "ei",
  "iu",
  "ie",
  "ia",
  "iao",
  "ui",
  "ua",
  "uo",
  "uai",
  "üe",
)
#let pinyin-nasal-vowels = (
  "an",
  "ang",
  "ong",
  "en",
  "eng",
  "in",
  "ing",
  "ian",
  "iang",
  "iong",
  "un",
  "uan",
  "uang",
  "ueng",
  "ün",
  "üan",
)
#let pinyin-special-vowels = (
  "er",
)
#let zkh = ("ü", "üe", "üan", "ün") // 撮口呼
#let hkh = ("u", "ua", "uo", "uai", "ui", "un", "uan", "uang", "ueng") // 合口呼
#let qch = ("i", "ia", "ie", "iao", "iu", "ian", "in", "iang", "ing", "iong") // 齐齿呼
#let kkh = ("a", "e", "ai", "ei", "ao", "ou", "an", "en", "ang", "eng", "o", "ong") // 开口呼

// 拼合规则:不为空串表示不可拼,能拼但拼写有变的另记在下方
#let comb = (ins, vs) => vs.map(v => ins.map(i => i + v)).flatten()
#let pinyin-spelling = (
  (
    comb(("",), ("ong",)) // ong 没有零声母形式
      // 唇音 b p m f:不拼撮口呼,u 组只拼 u
      + comb(("b", "p", "m", "f"), zkh + hkh.filter(v => v != "u"))
      + comb(("b", "p"), ("e", "ou", "ong"))
      + comb(("m",), ("ong",))
      + comb(("f",), ("e", "ai", "ao", "ong"))
      + comb(("b", "p"), ("ia", "iu", "iang", "iong"))
      + comb(("m",), ("ia", "iang", "iong"))
      + comb(("f",), qch)
      // 舌尖中音 d t
      + comb(("d",), ("o",))
      + comb(("t",), ("o", "en"))
      + comb(("d",), ("ia", "in", "iang", "iong"))
      + comb(("t",), ("ia", "iu", "in", "iang", "iong"))
      + comb(("d", "t"), ("ua", "uai", "uang", "ueng"))
      + comb(("d", "t"), zkh)
      // 鼻音 n 与边音 l:撮口呼只拼 ü üe
      + comb(("n",), ("o",))
      + comb(("l",), ("o", "en"))
      + comb(("n",), ("ia", "iong"))
      + comb(("l",), ("iong",))
      + comb(("n",), ("ua", "uai", "ui", "un", "uang", "ueng"))
      + comb(("l",), ("ua", "uai", "ui", "uang", "ueng"))
      + comb(("n", "l"), ("üan", "ün"))
      // 舌根音 g k h:不拼齐齿呼与撮口呼
      + comb(("g", "k", "h"), ("o",))
      + comb(("g", "k", "h"), qch)
      + comb(("g", "k", "h"), zkh)
      // 舌面音 j q x:只拼齐齿呼与撮口呼
      + comb(("j", "q", "x"), kkh)
      + comb(("j", "q", "x"), hkh)
      // 舌尖后音 zh ch sh r 与舌尖前音 z c s
      + comb(("zh", "ch", "sh", "r", "z", "c", "s"), qch.filter(v => v != "i"))
      + comb(("zh", "ch", "sh", "r", "z", "c", "s"), zkh)
      + comb(("zh", "ch", "sh", "r", "z", "c", "s"), ("ua", "uai", "uang", "ueng"))
      + comb(("zh", "ch", "sh", "g", "k", "h"), ("ueng",))
      + comb(("zh", "ch", "z", "c", "s"), ("o",))
      + comb(("ch", "c", "s"), ("ei",)) // 只有 zh sh z 拼 ei
      + comb(("sh",), ("ong",))
      + comb(("r",), ("a", "ai", "ei", "o"))
      + pinyin-initials.slice(1).map(i => i + "er") // er 不与声母相拼
  )
    .zip(("",) * 1000)
    .to-dict()
    + (
      // 零声母:y w 改写
      zkh.map(v => (v, "y" + v.replace("ü", "u")))
        + hkh.map(v => (v, "w" + ("u": "u", "ui": "ei", "un": "en").at(v, default: v.slice(1))))
        + qch.map(v => (v, "y" + ("i": "i", "in": "in", "ing": "ing", "iu": "ou").at(v, default: v.slice(1))))
        // j q x 后的 ü 组写作 u
        + zkh.map(v => ("j", "q", "x").map(i => (i + v, i + v.replace("ü", "u")))).fold((), (a, b) => a + b)
        + ("zhi", "chi", "shi", "ri", "zi", "ci", "si").map(s => (s, s))
    ).to-dict()
)

== Syllable = Initial + Vowel

#table(
  align: center + horizon,
  columns: 23,
  toprule(),
  table.header(
    table.cell(rowspan: 2)[
      *Vowels*\
      #zy[韵|母][yu4n|mu3]
    ],
    table.vline(),
    table.cell(colspan: 22)[*Initials* #zy[声|母][she1ng|mu3]],
    cmidrule(start: 1, end: 100),
    ..pinyin-initials.map(i => if i != "" [#i] else [$emptyset$]),
  ),
  midrule(),

  ..(pinyin-simple-vowels + pinyin-compound-vowels + pinyin-nasal-vowels + pinyin-special-vowels)
    .map(
      v => (
        (v,)
          + pinyin-initials.map(
            i => {
              let spell = i + v
              let actual = pinyin-spelling.at(spell, default: none)
              if actual == "" {
                return invalid
              }
              if actual == spell {
                return box(stroke: 1pt + black, inset: (x: 1pt, y: 2pt))[#actual]
              }
              if actual != none {
                highlight[#actual]
              }
            },
          )
      ),
    )
    .flatten(),

  bottomrule(),
)

#box[
  #align(horizon)[
    #box(width: 1em, height: 1em, clip: true, highlight("    ")): Same pronunciation, altered spelling;
    #box(width: 1em, height: 1em, stroke: 1pt + black): Same spelling, altered pronunciation;
    #invalid: Invalid
  ]
]

#blk[
  == Pinyin = Syllable + Tone
][
  #table(
    align: center + horizon,
    columns: 6,
    toprule(),
    table.header(
      table.cell(rowspan: 2)[Example],
      table.vline(),
      table.cell(colspan: 5)[*Tones* #zy[声|调][she1ng|dia4o]],
      cmidrule(start: 1, end: 100),
      [#sym.macron\ 1], [#sym.acute\ 2], [#sym.caron\ 3], [#sym.grave\ 4], [$emptyset$\ neutral],
    ),
    midrule(),

    [ma], zy[妈][ma1], zy[麻][ma2], zy[马][ma3], zy[骂][ma4], zy[吗][ma],
  )
]

= Japanese #zy[平|仮|名][ひら|が|な] / #zy[片|仮|名][カタ|カ|ナ]

#let jruby(rts, rb) = {
  rts.map(rt => zy[#rt][#rb]).join("/")
}

#columns(2)[
  #blk[
    == 50 syllables #zy[五|十|音][ご|じゅう|おん]
  ][
    #table(
      align: center + horizon,
      columns: 6,
      toprule(),
      table.header(
        table.cell(rowspan: 2)[
          *Consonants*\
          #zy[子|音][し|いん]
        ],
        table.vline(),
        table.cell(colspan: 5)[*Vowels* #zy[母|音][ぼ|いん]],
        cmidrule(start: 1, end: 100),
        zy[あ][a], zy[い][i], zy[う][u], zy[え][e], zy[お][o],
      ),
      midrule(),

      [$emptyset$],
      jruby(("あ", "ア"), "a"),
      jruby(("い", "イ"), "i"),
      jruby(("う", "ウ"), "u"),
      jruby(("え", "エ"), "e"),
      jruby(("お", "オ"), "o"),

      [k],
      jruby(("か", "カ"), "ka"),
      jruby(("き", "キ"), "ki"),
      jruby(("く", "ク"), "ku"),
      jruby(("け", "ケ"), "ke"),
      jruby(("こ", "コ"), "ko"),

      [s],
      jruby(("さ", "サ"), "sa"),
      jruby(("し", "シ"), "shi"),
      jruby(("す", "ス"), "su"),
      jruby(("せ", "セ"), "se"),
      jruby(("そ", "ソ"), "so"),

      [t],
      jruby(("た", "タ"), "ta"),
      jruby(("ち", "チ"), "chi"),
      jruby(("つ", "ツ"), "tsu"),
      jruby(("て", "テ"), "te"),
      jruby(("と", "ト"), "to"),

      [n],
      jruby(("な", "ナ"), "na"),
      jruby(("に", "ニ"), "ni"),
      jruby(("ぬ", "ヌ"), "nu"),
      jruby(("ね", "ネ"), "ne"),
      jruby(("の", "ノ"), "no"),

      [h],
      jruby(("は", "ハ"), "ha"),
      jruby(("ひ", "ヒ"), "hi"),
      jruby(("ふ", "フ"), "fu"),
      jruby(("へ", "ヘ"), "he"),
      jruby(("ほ", "ホ"), "ho"),

      [m],
      jruby(("ま", "マ"), "ma"),
      jruby(("み", "ミ"), "mi"),
      jruby(("む", "ム"), "mu"),
      jruby(("め", "メ"), "me"),
      jruby(("も", "モ"), "mo"),

      // や行与わ行缺 i e u 三段,与拼音表一样用灰块表示该位无假名
      [y],
      jruby(("や", "ヤ"), "ya"),
      invalid,
      jruby(("ゆ", "ユ"), "yu"),
      invalid,
      jruby(("よ", "ヨ"), "yo"),

      [r],
      jruby(("ら", "ラ"), "ra"),
      jruby(("り", "リ"), "ri"),
      jruby(("る", "ル"), "ru"),
      jruby(("れ", "レ"), "re"),
      jruby(("ろ", "ロ"), "ro"),

      [w],
      jruby(("わ", "ワ"), "wa"),
      invalid,
      invalid,
      invalid,
      jruby(("を", "ヲ"), "wo"),

      // ん 不属任何一段,单独成行
      cmidrule(start: 1, end: 6),
      [n],
      table.cell(colspan: 5)[#jruby(("ん", "ン"), "n")],
      bottomrule(),
    )
  ]

  #blk[
    == Voiced #zy[濁|音][だく|おん] (゛) \ Semi-voiced #zy[半|濁|音][はん|だく|おん] (゜)
  ][
    #table(
      align: center + horizon,
      columns: 6,
      toprule(),
      table.header(
        table.cell(rowspan: 2)[
          *Consonants*\
          #zy[子|音][し|いん]
        ],
        table.vline(),
        table.cell(colspan: 5)[*Vowels* #zy[母|音][ぼ|いん]],
        cmidrule(start: 1, end: 100),
        zy[あ][a], zy[い][i], zy[う][u], zy[え][e], zy[お][o],
      ),
      midrule(),

      [g],
      jruby(("が", "ガ"), "ga"),
      jruby(("ぎ", "ギ"), "gi"),
      jruby(("ぐ", "グ"), "gu"),
      jruby(("げ", "ゲ"), "ge"),
      jruby(("ご", "ゴ"), "go"),

      [z],
      jruby(("ざ", "ザ"), "za"),
      jruby(("じ", "ジ"), "ji"),
      jruby(("ず", "ズ"), "zu"),
      jruby(("ぜ", "ゼ"), "ze"),
      jruby(("ぞ", "ゾ"), "zo"),

      // ぢ づ 与 じ ず 同音,按读音标注
      [d],
      jruby(("だ", "ダ"), "da"),
      jruby(("ぢ", "ヂ"), "ji"),
      jruby(("づ", "ヅ"), "zu"),
      jruby(("で", "デ"), "de"),
      jruby(("ど", "ド"), "do"),

      [b],
      jruby(("ば", "バ"), "ba"),
      jruby(("び", "ビ"), "bi"),
      jruby(("ぶ", "ブ"), "bu"),
      jruby(("べ", "ベ"), "be"),
      jruby(("ぼ", "ボ"), "bo"),

      midrule(),

      [p],
      jruby(("ぱ", "パ"), "pa"),
      jruby(("ぴ", "ピ"), "pi"),
      jruby(("ぷ", "プ"), "pu"),
      jruby(("ぺ", "ペ"), "pe"),
      jruby(("ぽ", "ポ"), "po"),

      bottomrule(),
    )
  ]
]

#pagebreak(weak: true)

#columns(2)[
  #blk[
    == Contracted #zy[拗|音][よう|おん]
    i-row + small ゃ/ゅ/ょ = "merge two syllables"
  ][
    #table(
      align: center + horizon,
      columns: 4,
      toprule(),
      table.header(
        table.cell(rowspan: 2)[
          *Consonants*\
          #zy[子|音][し|いん]
        ],
        table.vline(),
        table.cell(colspan: 3)[*Small kana*],
        cmidrule(start: 1, end: 100),
        zy[ゃ][ya], zy[ゅ][yu], zy[ょ][yo],
      ),
      midrule(),

      [k], jruby(("きゃ", "キャ"), "kya"), jruby(("きゅ", "キュ"), "kyu"), jruby(("きょ", "キョ"), "kyo"),

      [s], jruby(("しゃ", "シャ"), "sha"), jruby(("しゅ", "シュ"), "shu"), jruby(("しょ", "ショ"), "sho"),

      [t], jruby(("ちゃ", "チャ"), "cha"), jruby(("ちゅ", "チュ"), "chu"), jruby(("ちょ", "チョ"), "cho"),

      [n], jruby(("にゃ", "ニャ"), "nya"), jruby(("にゅ", "ニュ"), "nyu"), jruby(("にょ", "ニョ"), "nyo"),

      [h], jruby(("ひゃ", "ヒャ"), "hya"), jruby(("ひゅ", "ヒュ"), "hyu"), jruby(("ひょ", "ヒョ"), "hyo"),

      [m], jruby(("みゃ", "ミャ"), "mya"), jruby(("みゅ", "ミュ"), "myu"), jruby(("みょ", "ミョ"), "myo"),

      [r], jruby(("りゃ", "リャ"), "rya"), jruby(("りゅ", "リュ"), "ryu"), jruby(("りょ", "リョ"), "ryo"),

      [g], jruby(("ぎゃ", "ギャ"), "gya"), jruby(("ぎゅ", "ギュ"), "gyu"), jruby(("ぎょ", "ギョ"), "gyo"),

      // じゃ行兼作 ぢゃ行
      [z], jruby(("じゃ", "ジャ"), "ja"), jruby(("じゅ", "ジュ"), "ju"), jruby(("じょ", "ジョ"), "jo"),

      [b], jruby(("びゃ", "ビャ"), "bya"), jruby(("びゅ", "ビュ"), "byu"), jruby(("びょ", "ビョ"), "byo"),

      [p], jruby(("ぴゃ", "ピャ"), "pya"), jruby(("ぴゅ", "ピュ"), "pyu"), jruby(("ぴょ", "ピョ"), "pyo"),

      bottomrule(),
    )
  ]

  #blk[
    == Double consonant #zy[促|音][そく|おん]
    っ/ッ double the next consonant = "short pause"
  ][
    #table(
      align: center + horizon,
      columns: 2,
      toprule(),
      table.header([Doubled], [Example]),
      midrule(),

      [kk], [#zy[が|][ga|]#highlight(zy[|っこ|][|kko|])#zy[|う][|u]],
      [ss], [#zy[い|][i|]#highlight(zy[|っさ|][|ssa|])#zy[|い][|i]],
      [tt], [#zy[き|][ki|]#highlight(zy[|って][|tte])],
      [pp], [#zy[い|][i|]#highlight(zy[|っぱ|][|ppa|])#zy[|い][|i]],

      bottomrule(),
    )
  ]

  #blk[
    == Long vowel #zy[長|音][ちょう|おん]
    hold the vowel for two beats
  ][
    #table(
      align: center + horizon,
      columns: 3,
      toprule(),
      table.header([Vowel], [Spelled], [Example]),
      midrule(),

      [a], [あ], [#zy[お|][o|]#highlight(zy[|かあ|][|kaa|])#zy[|さん][|san]],
      [i], [い], [#zy[お|][o|]#highlight(zy[|にい|][|nii|])#zy[|さん][|san]],
      [u], [う], [#highlight(zy[くう|][kuu|])#zy[|き][|ki]],

      [e],
      [い / え],
      [#zy[せん|][sen|]#highlight(zy[|せい][|sei]) / #zy[お|][o|]#highlight(zy[|ねえ|][|nee|])#zy[|さん][|san]],

      [o], [う / お], [#highlight(zy[とう|][tou|])#zy[|きょう][|kyou] / #highlight(zy[とお|][too|])#zy[|い][|i]],
      [a/i/u/e/o], [ー], [#highlight(zy[コー|][koo|])#highlight(zy[|ヒー][|hii])],

      bottomrule(),
    )
  ]
]

= Korean #zy[한|글][han|geul]

// 字母:上方为初声读音,下方灰色为收音读音
#let jamo(l, ini, fin) = [#zy[#l][#ini]\ #pad(top: -0.8em, text(size: 0.65em)[#fin])]

#grid(columns: (2fr, 1fr))[
  #blk[
    == Consonants #zy[자|음][ja|eum]
    #text(size: 0.9em)[Top: as initial; bottom: as final]
  ][
    #table(
      align: center + horizon,
      columns: 6,
      toprule(),
      table.header(
        table.cell(rowspan: 2)[*Place*],
        table.vline(),
        table.cell(colspan: 5)[*Manner*],
        cmidrule(start: 1, end: 100),
        [*Plain*], [*Tense*], [*Aspirated*], [*Nasal*], [*Liquid*],
      ),
      midrule(),

      [*Velar* #zy[아|음][a|eum]],
      jamo("ㄱ", "g", "k"), jamo("ㄲ", "kk", "k"), jamo("ㅋ", "k", "k"), invalid, invalid,

      [*Alveolar* #zy[설|음][seol|eum]],
      jamo("ㄷ", "d", "t"), jamo("ㄸ", "tt", "∅"), jamo("ㅌ", "t", "t"), jamo("ㄴ", "n", "n"), jamo("ㄹ", "r", "l"),

      [*Bilabial* #zy[순|음][sun|eum]],
      jamo("ㅂ", "b", "p"), jamo("ㅃ", "pp", "∅"), jamo("ㅍ", "p", "p"), jamo("ㅁ", "m", "m"), invalid,

      table.cell(rowspan: 2)[*Dental* #zy[치|음][chi|eum]],
      jamo("ㅅ", "s", "t"), jamo("ㅆ", "ss", "t"), invalid, invalid, invalid,

      jamo("ㅈ", "j", "t"), jamo("ㅉ", "jj", "∅"), jamo("ㅊ", "ch", "t"), invalid, invalid,

      [*Glottal* #zy[후|음][hu|eum]],
      jamo("ㅇ", "∅", "ng"), invalid, jamo("ㅎ", "h", "t"), invalid, invalid,

      bottomrule(),
    )
  ]
][
  #blk[
    == Vowels #zy[모|음][mo|eum]
  ][
    #table(
      align: center + horizon,
      columns: 3,
      toprule(),
      table.header([*Base*], [*+i/y*], [*+u/w*]),
      midrule(),

      zy[ㅏ][a], zy[ㅑ][ya], zy[ㅘ][wa],
      zy[ㅓ][eo], zy[ㅕ][yeo], zy[ㅝ][wo],
      zy[ㅗ][o], zy[ㅛ][yo], zy[ㅚ][oe],
      zy[ㅜ][u], zy[ㅠ][yu], zy[ㅟ][wi],
      zy[ㅐ][ae], zy[ㅒ][yae], zy[ㅙ][wae],
      zy[ㅔ][e], zy[ㅖ][ye], zy[ㅞ][we],
      zy[ㅡ][eu], zy[ㅢ][ui], invalid,
      zy[ㅣ][i], invalid, invalid,

      bottomrule(),
    )
  ]
]

#blk[
  == Syllable blocks #zy[음|절][eum|jeol]
  Character = Syllable = Initial + Vowel [+ Final]\
  #text(size: 0.9em)[Reading: left-to-right, top-to-bottom]
][
  #table(
    align: center + horizon,
    columns: 9,
    toprule(),
    table.header(
      [Example], zy[가][ga], zy[고][go], zy[아][a], zy[강][gang], zy[곰][gom], zy[과][gwa], zy[왜][wae], zy[닭][dak]
    ),
    midrule(),

    [*Layout*], [upright], [flat], [upright], [upright], [flat], [mixed], [mixed], [upright],
    [*Initial*], zy[ㄱ][g], zy[ㄱ][g], zy[ㅇ][∅], zy[ㄱ][g], zy[ㄱ][g], zy[ㄱ][g], zy[ㅇ][∅], zy[ㄷ][d],
    [*Vowel*], zy[ㅏ][a], zy[ㅗ][o], zy[ㅏ][a], zy[ㅏ][a], zy[ㅗ][o], zy[ㅘ][wa], zy[ㅙ][wae], zy[ㅏ][a],
    [*Final*], [$emptyset$], [$emptyset$], [$emptyset$], zy[ㅇ][ng], zy[ㅁ][m], [$emptyset$], [$emptyset$], zy[ㄺ][k],

    bottomrule(),
  )
]
