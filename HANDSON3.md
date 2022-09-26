# Hands-on 3. Run test with predictive test selection

In this section, edit`.github/workflows/re-merge.md` and confirm your model performance and how to adjust subset target.
You'll do

1. Confirm model performance
1. Disable observation mode
1. Change subset target value
1. Add new test case


Before starting it, make a new branch `PR2`.

```
$ git switch -c PR2
$ git push origin PR2
```
 And create a PR from `PR2` branch to `main` branch.

## Confirm model performance

TODO(Konboi): explain simulation page and paste screen shot

## Stop observation mode

You could confirm subset impact, so disable observation mode.

`.github/workflows/pre-merge.yml`
```diff
       - name: Launchable record session
         id: issue_test_session
         run: |
-          launchable record session --build ${{ github.run_id }} --observation > test_session.txt
+          launchable record session --build ${{ github.run_id }} > test_session.txt
           test_session=$(cat test_session.txt)
           echo $test_session
           echo "::set-output name=test_session::$test_session"
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
       - name: Launchable subset
         run: |
           mvn test-compile
-          launchable subset --session $( cat test_session.txt ) --target 50% maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset.txt
+          launchable subset --session $( cat test_session.txt ) --target 75% maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset.txt
           cat launchable-subset.txt
       - name: Test
         run: mvn test -Dsurefire.includesFile=launchable-subset.txt
```

Subset result will change like below. You can confirm the amount of subset candidates was changed from 2 to 3.
```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            3 |                  74.9972 |                   0.99965  |
| Remainder |            1 |                  25.0028 |                   0.333267 |
|           |              |                          |                            |
| Total     |            4 |                 100      |                   1.33292  |
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
example.MulTest
example.AddTest
```

`launchable record test results on GitHub Actions`

```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             4 |             4 |              3 |              1 |                 0.0001 |
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

Next, let's run test in parallel.



