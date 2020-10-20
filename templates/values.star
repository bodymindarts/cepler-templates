load("@ytt:data", "data")
load("@ytt:assert", "assert")
load("@ytt:yaml", "yaml")

ci = yaml.decode(data.values.ci)

ci["processor"].setdefault("debug", False)
ci["driver"].setdefault("secrets")

cepler = yaml.decode(data.values.cepler)

values = {"ci": ci, "cepler": cepler}
