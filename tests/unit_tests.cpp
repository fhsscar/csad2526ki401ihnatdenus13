#include <gtest/gtest.h>
#include "../math_operations.cpp"
#include <iostream>

TEST(MathOperationsTest, AddTest) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    int result = RUN_ALL_TESTS();
    std::cout << "Press Enter to exit..." << std::endl;
    std::cin.get(); // Чекає натискання Enter
    return result;
}