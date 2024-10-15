import XCTest
@testable import FlipMe_OpenSource

class ImagesLibraryPickerModelTests: XCTestCase {

    var mockLibrary: MockImagesLibraryModel!
    var sutForAnyGame: ImagesLibraryPickerModel!
    
    override func setUp() {
        super.setUp()
        mockLibrary = MockImagesLibraryModel()
        mockLibrary.data = [.AnyImage:[TestsValues.String1,TestsValues.String2,TestsValues.String3]
                            ,.ImageForCardsWithDoubleImages:[TestsValues.String3]]
        sutForAnyGame = ImagesLibraryPickerModel(using: mockLibrary)
    }

    override func tearDown() {
        mockLibrary = nil
        sutForAnyGame = nil
    }

    func test_Initialization_WithLibraryAndAnyGame() {
        let sut = sutForAnyGame!

        XCTAssertTrue(sut.delivered.isEmpty)
        XCTAssertEqual(sut.valuesToPickByPriority.first, mockLibrary.availableSet)
        XCTAssertEqual(sut.remainingCount(for: .AnyImage), mockLibrary.availableSet.count)
    }
    
    func test_Initialization_WithLibraryAndDoubleImages() {
        let sut = ImagesLibraryPickerModel(using: mockLibrary)

        XCTAssertTrue(sut.delivered.isEmpty)
        XCTAssertEqual(sut.remainingCount(for: .ImageForCardsWithDoubleImages)
                       , mockLibrary.filter(mockLibrary.availableSet, for: .ImageForCardsWithDoubleImages).count)
    }
    
    func test_popRandom_WithRegularLibrary_ShouldUpdate() {
        var sut = sutForAnyGame!

        let image = sut.popRandom(for: .AnyImage)!
        
        XCTAssertFalse(sut.delivered.isEmpty)
        XCTAssertEqual(sut.delivered, [image])
        XCTAssertEqual(sut.valuesToPickByPriority.first, mockLibrary.availableSet.subtracting([image]))
        XCTAssertEqual(sut.remainingCount(for: .AnyImage), mockLibrary.availableSet.count-1)
    }


    
    func test_popRandom_ShouldBeRandom() {
        var bigSet = Set<ImageName>()
        let bigSize = 1000
        (1...bigSize).forEach{ bigSet.insert("\(TestsValues.String)-\($0)") }
        let mockBigLibrary = MockImagesLibraryModel()
        mockBigLibrary.data = [.AnyImage:bigSet]
        var sut = ImagesLibraryPickerModel(using: mockBigLibrary)
        
        let sutPoppedValues1 = sut.popRandom(for: .AnyImage)
        sut.reset(renewingImages: false)
        let sutPoppedValues2 = sut.popRandom(for: .AnyImage)
        
        XCTAssertNotEqual(sutPoppedValues1, sutPoppedValues2)
    }
    
    func test_popRandom_AfterPoppingAllLibrary_ShouldBeNil() {
        var sut1 = ImagesLibraryPickerModel(using: MockImagesLibraryModelWith3Images())
        var sut1LastPopped : ImageName?
        
        (1...3).forEach { _ in sut1LastPopped = sut1.popRandom(for: .AnyImage) }
        let sut1AfterLastPopped = sut1.popRandom(for: .AnyImage)
        
        XCTAssertNotNil(sut1LastPopped)
        XCTAssertNil(sut1AfterLastPopped)
    }
    
    func test_popRandom_AfterResetWhenNotUsed() {
        var sut2 = ImagesLibraryPickerModel(using: mockLibrary)
        let librarySize = mockLibrary.availableSet.count
        var sut2LastPopped : ImageName?

        sut2.reset(renewingImages: true)
        let sut2FirstPopped = sut2.popRandom(for: .AnyImage)
        (1...librarySize-1).forEach { _ in sut2LastPopped = sut2.popRandom(for: .AnyImage) }
        let sut2AfterLastPopped = sut2.popRandom(for: .AnyImage)
        
        XCTAssertNotNil(sut2FirstPopped)
        XCTAssertNotNil(sut2LastPopped)
        XCTAssertNil(sut2AfterLastPopped)
    }
    func test_popRandom_WithPreviousPickerFullyUsed() {
        var sut1 = ImagesLibraryPickerModel(using: mockLibrary)
        let librarySize = mockLibrary.availableSet.count
        var sut2LastPopped : ImageName?
        
        (1...librarySize).forEach { _ in _ = sut1.popRandom(for: .AnyImage) }
        var sut2 = ImagesLibraryPickerModel(using: mockLibrary)
        let sut2FirstPopped = sut2.popRandom(for: .AnyImage)
        (1...librarySize-1).forEach { _ in sut2LastPopped = sut2.popRandom(for: .AnyImage) }
        let afterLastPopped = sut2.popRandom(for: .AnyImage)
        
        XCTAssertNotNil(sut2FirstPopped)
        XCTAssertNotNil(sut2LastPopped)
        XCTAssertNil(afterLastPopped)
    }

    func test_popRandom_AfterResetWithRenewingImagesAndBigSet() {
        var bigSet = Set<ImageName>()
        let bigSize = 100
        let halfSize = 50
        (1...bigSize).forEach{ bigSet.insert("\(TestsValues.String)-\($0)") }
        let mockBigLibrary = MockImagesLibraryModel()
        mockBigLibrary.data = [.AnyImage:bigSet]
        var sut1 = ImagesLibraryPickerModel(using: mockBigLibrary)
        
        var sut1PoppedFirstHalf = Set<ImageName?>()
        var sut1PoppedSecondHalf = Set<ImageName?>()
        (1...halfSize).forEach { _ in sut1PoppedFirstHalf.insert(sut1.popRandom(for: .AnyImage)) }
        
        sut1.reset(renewingImages: true)
        (halfSize+1...bigSize).forEach { _ in sut1PoppedSecondHalf.insert(sut1.popRandom(for: .AnyImage)) }
        
        XCTAssertFalse(sut1PoppedFirstHalf.contains(nil))
        XCTAssertFalse(sut1PoppedSecondHalf.contains(nil))
        XCTAssertTrue(sut1PoppedFirstHalf.intersection(sut1PoppedSecondHalf).isEmpty)
    }
    
}
