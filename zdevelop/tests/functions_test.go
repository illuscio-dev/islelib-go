package tests

import (
	"github.com/stretchr/testify/assert"
	"islelib"
	"testing"
)


func TestCastSpell(test *testing.T) {
	assert.Equal(test, "Avada Kedavra", islelib.CastSpell())
}
