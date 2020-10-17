load("@ytt:data", "data")
load("@ytt:assert", "assert")
load("@ytt:yaml", "yaml")

# export
ci = yaml.decode(data.values.ci)

ci["processor"].setdefault("debug", False)

if ci["driver"]["type"] == "concourse":
  ci["driver"].setdefault("secrets")
end

cepler = yaml.decode(data.values.cepler)

values = {"ci": ci, "cepler": cepler}
