#import "@preview/imprecv:1.0.1": *

#let education = yaml("cv/education.yaml")
#let misc = yaml("cv/misc.yaml")
#let personal = yaml("cv/personal.yaml")
#let summary = yaml("cv/summary.yaml")
#let projects = yaml("cv/projects.yaml")
#let skills = yaml("cv/skills.yaml")
#let work = yaml("cv/work.yaml")

#let cvdata = personal + summary + skills + projects + work + education + misc

#let uservars = (
    headingfont: "Garamond Libre",
    bodyfont: "Garamond Libre",
    fontsize: 10pt, // 10pt, 11pt, 12pt
    linespacing: 6pt,
    sectionspacing: 0pt,
    showAddress:  true, // true/false show address in contact info
    showNumber: true,  // true/false show phone number in contact info
    showTitle: true,   // true/false show title in heading
    headingsmallcaps: false, // true/false use small caps for headings
    sendnote: false, // set to false to have sideways endnote
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // add custom document style rules here
//
//      doc
// }

#let customrules(doc) = {
    // add custom document style rules here
    set page(
        paper: "us-letter", // a4, us-letter
        numbering: none,
        number-align: center, // left, center, right
        margin: 1.25cm, // 1.25cm, 1.87cm, 2.5cm
    )

    doc
}

#let cvinit(doc) = {
    doc = setrules(uservars, doc)
    doc = showrules(uservars, doc)
    doc = customrules(doc)

    doc
}

// each section body can be overridden by re-declaring it here
// #let cveducation = []

#let cvsummary(info, title: "Summary", isbreakable: true) = {
  let summary = info.summary
  if summary != none and summary != "" {
    block(breakable: isbreakable)[
      == #title
      #eval(summary, mode: "markup")
      #v(0.3em)  // adds a little breathing room below the summary
    ]
  }
}

// ========================================================================== //

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)
#cvsummary(cvdata)
#cveducation(cvdata)

#cvwork(cvdata)
#cvprojects(cvdata)

#cvaffiliations(cvdata)
#cvskills(cvdata)


// #cvawards(cvdata)
// #cvpublications(cvdata)
// #cvcertificates(cvdata)
// #cvreferences(cvdata)
// #endnote(uservars)
