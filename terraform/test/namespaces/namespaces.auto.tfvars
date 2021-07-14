namespaces = [
  {
    name    = "apps",
    product = "Test Apps Namespace",
    owner   = "kasjanov@hotmail.com",
    pods    = 20,
    envs = [
      "test",
    ],
    volumes      = 10,
    volumes_size = "10Gi",

    // Annotations and labels for objects
    annotations = {
      "k8s.aws-gopoints.ru/managedby" = "Terraform",
    },
    labels = {
      component = "apps",
    },
  },
]
