from pipeline1.lib.logging import log

def get_partial_matches(term: str, item_dict: dict[str, str]) -> list[str]:
    matches = []
    for key in item_dict:
        if term in key:
            matches.append(key)
    return matches


def permissive_match(term: str, item_list: list[str]) -> str:
    """
    Search for the term in a permissive way.
    Only one list item must match.
    The matching is case-insensitive and ignores spaces, underscores, and hyphens.
    """
    #todo: ensure item_list is unique by making it a set.
    normalized_term = term.lower().replace(" ", "").replace("_", "").replace("-", "")
    item_dict = {}
    for item in item_list:
        normalized_item = item.lower().replace(" ", "").replace("_", "").replace("-", "")
        item_dict[normalized_item] = item
        if normalized_item == normalized_term:
            return item

    partial_matches = get_partial_matches(normalized_term, item_dict)
    if len(partial_matches) == 1:
        log.info(f"{term} is a unique partial match of {item_dict[partial_matches[0]]}")
        return item_dict[partial_matches[0]]
    else:
        match_list = [item_dict[match] for match in partial_matches]
        log.info(f"Do you mean: {', '.join(match_list)}?")

    return ""