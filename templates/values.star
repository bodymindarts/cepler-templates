load("@ytt:data", "data")
load("@ytt:assert", "assert")
load("@ytt:yaml", "yaml")

# export
ci = yaml.decode(data.values.ci)
cepler = yaml.decode(data.values.cepler)

if ci["driver"]["type"] == "concourse":
  ci["driver"].setdefault("secrets")
end

values = {"ci": ci, "cepler": cepler}
