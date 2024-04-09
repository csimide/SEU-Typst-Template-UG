// Authors: csimide, OrangeX4
// Tested only on GB-7714-2015-Numeric
#let bilingual-bibliography(
  mapping: (:),
  cont
) = {
  assert(bibliography != none, message: "请传入带有 source 的 bibliography 函数。")
  
  // Please fill in the remaining mapping table here
  mapping = (
    "等": "et al",
    "卷": "Vol.",
    "册": "Bk.",
    "译": "tran"
  ) + mapping

  let to-string(content) = {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("child") {
      to-string(content.child)
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  show grid.cell.where(x: 1): it => {
    // 后续的操作是对 string 进行的。
    let ittext = to-string(it)
    // 判断是否为中文文献：去除特定词组后，仍有至少两个连续汉字。
    let pureittext = ittext.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
    if pureittext.find(regex("\p{sc=Hani}{2,}")) != none {
      ittext
    } else {
      // 不是中文文献，进行替换
      // 第xxx卷、第xxx册的情况：变为 Vol. XXX 或 Bk. XXX。
      let reptext = ittext
      reptext = reptext.replace(regex("(第\s?)?\d+\s?[卷册]"), itt => {
        if itt.text.contains("卷") {"Vol. "} else {"Bk. "}
        itt.text.find(regex("\d+"))
      })
      // 第xxx版/第xxx本的情况：变为 1st ed 格式。
      reptext = reptext.replace(regex("(第\s?)?\d+\s?[版本]"), itt => {
        let num = itt.text.find(regex("\d+"))
        num
        if num.clusters().len() == 2 and num.clusters().first() == "1" {
          "th"
        } else {
          (
            "1": "st",
            "2": "nd",
            "3": "rd"
          ).at(num.clusters().last(), default: "th")
        }
        " ed"
      })
      // 其他情况：直接替换
      reptext = reptext.replace(regex("\p{sc=Hani}+"), itt => {
        mapping.at(itt.text, default: itt.text)
      })
      reptext
    }
  }

  set text(lang: "zh")
  cont
}