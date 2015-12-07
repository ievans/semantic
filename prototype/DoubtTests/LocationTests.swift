final class LocationTests: XCTestCase {
	func testExplorationOfATermBeginsAtTheExploredTerm() {
		assert(term.explore().it, ==, term)
	}

	func testCannotMoveUpwardsAtTheStartOfAnExploration() {
		assert(term.explore().outOf?.it, ==, nil)
	}

	func testCannotMoveSidewaysAtTheStartOfAnExploration() {
		assert(term.explore().left?.it, ==, nil)
		assert(term.explore().right?.it, ==, nil)
	}

	func testCannotMoveDownwardsFromLeaves() {
		assert(leafA.explore().into?.it, ==, nil)
	}

	func testCanMoveDownwardsIntoBranches() {
		assert(term.explore().into?.it, ==, leafA)
	}

	func testCanMoveBackUpwards() {
		assert(term.explore().into?.outOf?.it, ==, term)
	}

	func testCannotMoveLeftwardsFromFirstChildOfBranch() {
		assert(term.explore().into?.left?.it, ==, nil)
	}

	func testCanMoveRightwardsFromLeftmostChildOfLongBranch() {
		assert(term.explore().into?.right?.it, ==, leafB)
	}

	func testCanExploreBranchesDeeply() {
		assert(term.explore().into?.right?.right?.into?.it, ==, innerLeafB)
	}

	func testCanMoveBackUpwardsFromDeepExplorations() {
		assert(term.explore().into?.right?.right?.into?.right?.outOf?.outOf?.it, ==, term)
	}

	func testCanReturnToStartOfExplorationFromArbitrarilyDeepNodes() {
		assert(term.explore().into?.right?.right?.into?.right?.root.it, ==, term)
	}

	func testSequenceIsPreOrderDepthFirstTraversal() {
		assert(term.explore().map { $0.it.extract }, ==, [ 0, 1, 2, 3, 5, 4 ])
	}

	func testModifyReplacesSubtrees() {
		assert(term.explore().into?.modify(const(leafB)).right?.outOf?.it, ==, Cofree(0, .Indexed([ leafB, leafB, keyed ])))
	}

	func testMultipleModificationsReplaceMultipleSubtrees() {
		assert(term.explore().into?.modify(const(leafB)).right?.modify(const(leafA)).outOf?.it, ==, Cofree(0, .Indexed([ leafB, leafA, keyed ])))
	}

	func testModificationsPreserveKeys() {
		assert(keyed.explore().into?.modify(const(leafA)).root.it, ==, Cofree(3, .Keyed([ "a": innerLeafA, "b": leafA ])))
	}

	func testDeepModificationsReplaceDeepSubtrees() {
		assert(term.explore().into?.modify(const(leafB)).right?.modify(const(leafA)).right?.into?.modify(const(innerLeafA)).right?.modify(const(innerLeafB)).root.it, ==, Cofree(0, .Indexed([ leafB, leafA, Cofree(3, .Keyed([ "a": innerLeafB, "b": innerLeafA ])) ])))
	}

	func testModificationsCanRefineDiffs() {
		assert(diff.explore().into?.right?.modify(const(refined)).root.it, ==, Free.Roll(0, .Indexed([ Free.Roll(1, .Leaf("a string")), refined ])))
	}
}


private let leafA = Cofree(1, .Leaf("a string"))
private let leafB = Cofree(2, .Leaf("b string"))
private let innerLeafA = Cofree(4, .Leaf("a nested string"))
private let innerLeafB = Cofree(5, .Leaf("b nested string"))
private let keyed = Cofree(3, .Keyed([
	"a": innerLeafA,
	"b": innerLeafB,
]))
private let term: Cofree<String, Int> = Cofree(0, .Indexed([
	leafA,
	leafB,
	keyed,
]))

private let diff: Free<String, Int, Patch<Cofree<String, Int>>> = Free.Roll(0, .Indexed([
	Free.Roll(1, .Leaf("a string")),
	Free.Pure(Patch.Replace(leafA, leafB)), // coarse-grained diff of two leaf nodes
]))
// fine-grained diff of same
private let refined = Free.Roll(2, .Indexed([
	Free.Pure(Patch.Replace(Cofree(1, .Leaf("a")), Cofree(2, .Leaf("b")))),
	Free.Roll(4, .Leaf(" ")),
	Free.Roll(5, .Leaf("s")),
	Free.Roll(6, .Leaf("t")),
	Free.Roll(7, .Leaf("r")),
	Free.Roll(8, .Leaf("i")),
	Free.Roll(9, .Leaf("n")),
	Free.Roll(10, .Leaf("g")),
]))


import Assertions
@testable import Doubt
import Prelude
import XCTest