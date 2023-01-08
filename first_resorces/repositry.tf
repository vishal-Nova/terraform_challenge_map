
resource "github_repository" "github-test-terraform" {
  name = "first-repo-from-terraform"


  visibility = "public"

  auto_init = true

}

output "terraform_repo_url" {

  value = github_repository.github-test-terraform.ssh_clone_url

}