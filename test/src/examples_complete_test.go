package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())
	randID := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	keyName := terraform.Output(t, terraformOptions, "key_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-ec2-bastion-" + randID + "-ssh-key", keyName)

	// Run `terraform output` to get the value of an output variable
	privateDns := terraform.Output(t, terraformOptions, "private_dns")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, privateDns, ".us-east-2.compute.internal")

	// Run `terraform output` to get the value of an output variable
	publicDns := terraform.Output(t, terraformOptions, "public_dns")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, publicDns, ".us-east-2.compute.amazonaws.com")

	// Run `terraform output` to get the value of an output variable
	role := terraform.Output(t, terraformOptions, "role")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-ec2-bastion-"+randID, role)

	// Run `terraform output` to get the value of an output variable
	securityGroupName := terraform.Output(t, terraformOptions, "security_group_name")
	expectedSecurityGroupName := "eg-test-ec2-bastion-" + randID
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedSecurityGroupName, securityGroupName)

	// Run `terraform output` to get the value of an output variable
	securityGroupID := terraform.Output(t, terraformOptions, "security_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, securityGroupID, "sg-", "SG ID should contains substring 'sg-'")

	// Run `terraform output` to get the value of an output variable
	securityGroupARN := terraform.Output(t, terraformOptions, "security_group_arn")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, securityGroupARN, "arn:aws:ec2", "SG ID should contains substring 'arn:aws:ec2'")
}
