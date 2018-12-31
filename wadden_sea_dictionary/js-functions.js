function wordlist_text(index) {
    var s, scientific;
    if(language === undefined) s = "";
    else s = vocabularyModel.at(index, language);
    scientific = vocabularyModel.at(index, 4);
    return s + (scientific === "" ? "" : " (<i>" + scientific + "</i>)")
}

function wordlist_section(index) {
    var s;
    if(language === undefined) s = "";
    else s = vocabularyModel.at(index, language+5);
    return s;
}
