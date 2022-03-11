/*
 * Copyright (C) 2018-2022 by George Cave - gcave@stablecoder.ca
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * Original code https://raw.githubusercontent.com/StableCoder/cmake-scripts/main/example/src/asan_fail.cpp
*/

int main(int argc, char * argv[]) {
    int *array = new int[100];
    delete[] array;
    return array[argc];  // BOOM
}
