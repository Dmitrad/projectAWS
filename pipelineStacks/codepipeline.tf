
resource "aws_iam_role" "codepipeline_role_aws" {
  name = "pipeline-team2-aws"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codepipeline_policy_aws" {
  name = "pipeline-policy-team2-aws"
  #role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "ec2:*",
        "ssm:*",
        "*"
      ],
      "Resource": [
        "${aws_s3_bucket.example.arn}",
        "${aws_s3_bucket.example.arn}/*",
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.codepipeline_role_aws.name
  policy_arn = aws_iam_policy.codepipeline_policy_aws.arn
}

#####################
# codepipeline code
#####################

resource "aws_codepipeline" "codepipeline_aws" {
  name     = "team2-pipeline-autoscaling"
  role_arn = aws_iam_role.codepipeline_role_aws.arn

  artifact_store {
    location = aws_s3_bucket.example.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.GitHubOwner
        Repo       = var.GitHubRepo
        Branch     = "main"
        OAuthToken = data.aws_ssm_parameter.git-token.value
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "team2-project-aws"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = "MyDemoApplicationAws"
        DeploymentGroupName = "MyDeploymentGroupAws"
      }
    }
  }
}
