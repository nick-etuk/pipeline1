def permissive_match(term: str, list_of_strings: list[str]) -> bool:
    """
    Search for the term in a permissive way.
    Only one list item must match.
    The matching is case-insensitive and ignores spaces, underscores, and hyphens.
    """
    normalized_term = term.lower().replace(" ", "").replace("_", "").replace("-", "")
    normalized_list = [item.lower().replace(" ", "").replace("_", "").replace("-", "") for item in list_of_strings]
    for item in normalized_list:
        if item == normalized_term:
            return True

    # todo: do we want partial matches?
    return False