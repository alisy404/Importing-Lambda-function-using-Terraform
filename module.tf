#Here are we defining the path module
module "path" {
  source = "./modules/path"
}

# Here we are defining the output variables for the path module. This will allow us to reference the module's outputs in other parts of our configuration.
output "root" {
  value = module.path.root
}

# Here are we defining the output variables for the path module. This will allow us to reference the module's outputs in other parts of our configuration.
output "module" {
  value = module.path.module
}