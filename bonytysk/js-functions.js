function wordlist_text(index) {
    return vocabularyModel.at(index, 0);
}

function wordlist_section(index) {
    return vocabularyModel.at(index, 0).charAt(0).toUpperCase();
}
