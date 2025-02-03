# Hands-on 3. Run test with predictive test selection

In this section, edit`.github/workflows/pre-merge.md` and introduce the **subset** command without the observation option.
You'll do

1. Disable observation mode
1. Change subset target value
1. Add new test case

Before starting it, make a new branch `PR2`.

```
$ git switch -c PR2
$ git commit --allow-empty -m "introduce subset command"
$ git push origin PR2
```
 And create a pull request from `PR2` branch to `main` branch.

## Stop observation mode

`.github/workflows/pre-merge.yml`
```diff
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          mvn test-compile
-         launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
+         launchable subset --target 50% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
        run: mvn test
```

You can confirm the tested test case count was changed like below.

**Test Log**

- Before
```
[INFO] Results:
[INFO]
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
```

- After
```
[INFO] Results:
[INFO]
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
```

**Subset Result**

- Before
```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             4 |             4 |              4 |              0 |                 0.0001 |
```

- After
```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             2 |             2 |              2 |              0 |                 0.0001 |
```

 ## Change subset target value

 There are three subset type.

 ```
 launchable subset \
    # one of:
    --target [PERCENTAGE]
    # or
    --confidence [PERCENTAGE]
    # or
    --time [STRING] \
    [other options...]
```

This time, change target value and confirm the result will change.

```diff
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          mvn test-compile
-         launchable subset --target 50% maven src/test/java > launchable-subset.txt
+         launchable subset --target 25% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
```

Subset result will change like below. You can confirm the amount of subset candidates was changed from 2 to 1.
```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            1 |                  9.63855 |                  0.0133333 |
| Remainder |            3 |                 90.3614  |                  0.125     |
|           |              |                          |                            |
| Total     |            4 |                100       |                  0.138333  |
```

## Add new test case

In this section, add new function and test then confirm the added test and related test will be tested.
You'll add new function `Exponentiation`.

First add test code and dummy method to prevent compile error.

`src/test/java/example/ExponentiationTest.java`
```java
package example;

import org.junit.Test;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;


public class ExponentiationTest {
  @Test
  public void exponentiation() {
    assertThat(new Exponentiation().calc(2, 5), is(32));
  }
}
```

`src/main/java/example/Exponentiation.java`
```java
package example;

public class Exponentiation {
  public int calc(int x, int y) {
    return 0;
  }
}
```

Then, this test will fail

```
Run `launchable inspect subset --subset-id xxx` to view full subset details
example.ExponentiationTest
example.SubTest
```

`launchable record test results on GitHub Actions`

```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             2 |             2 |              1 |              1 |                 0.0001 |
```

Let's implement code

```java
 public class Exponentiation {
   public int calc(int x, int y) {
-    return 0;
+    int exp = 1;
+    for (; y != 0; y--) {
+      exp = new Mul().calc(exp, x);
+    }
+    return exp;
   }
 }
```

You can confirm `ExponentiationTest.java` and `MulTest.java` were selected.

Finish, this section.

You learned how to see model performance and use it. And, you can confirm new test and related test were selected by launchable subset.

___

Prev: [Hands-on 2](HANDSON2.md)


