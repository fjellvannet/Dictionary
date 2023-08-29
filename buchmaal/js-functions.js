function wordlist_text(index) {
    var s;
    s = vocabularyModel.at(index, 1);
    if(s === "") {
        return vocabularyModel.at(index, 0);
    }
    else {
        return vocabularyModel.at(index, 0) + " <i>" + s + "</i>";
    }
}

function backgroundSource() {
    return "qrc:/images/background/background-nor"
}
