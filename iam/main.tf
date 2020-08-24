########## Create the Updraft Plus IAM user
resource "aws_iam_user" "iam-user1" {
  name = "updraft-plus-tf"
}

########## Grab referene to the built-in AWS policy 
data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

########## Assign the policy to the user
resource "aws_iam_user_policy_attachment" "S3FullAccess-user-policy-attach" {
  user = aws_iam_user.iam-user1.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

###########
# Create Access and Secret Keys (manually or work out secured manner to do so??)