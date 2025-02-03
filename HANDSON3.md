# Hands-on 3. Run test with predictive test selection

In this section, edit`.github/workflows/pre-merge.md` and introduce the **subset** command without the observation option.

You will:

1. Disable observation mode
1. Change subset target value
1. Add a new test case

Before you begin, create a new branch named `PR2`.

```
$ git switch -c PR2
$ git commit --allow-empty -m "introduce subset command"
$ git push origin PR2
```
 Then, create a pull request from `PR2` branch to `main` branch.

## Stop observation mode

Edit `.github/workflows/pre-merge.yml` as follows:
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

You can confirm that the number of test cases executed has changed as follows:

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

This time, change target value and confirm that the result changes.

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

The subset result will change as shown below. You can confirm that the number of subset candidates changes from 2 to 1.
```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            1 |                  9.63855 |                  0.0133333 |
| Remainder |            3 |                 90.3614  |                  0.125     |
|           |              |                          |                            |
| Total     |            4 |                100       |                  0.138333  |
```

## Add new test case

In this section, add a new function along with its test, and confirm that both the added test and its related tests are executed. You will add new function called `Exponentiation`.

First, add test code and dummy method to prevent compile errors.

Create the file `src/test/java/example/ExponentiationTest.java`
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

Then, create the file `src/main/java/example/Exponentiation.java`
```java
package example;

public class Exponentiation {
  public int calc(int x, int y) {
    return 0;
  }
}
```

At this point, the  test will fail:

```
Run `launchable inspect subset --subset-id xxx` to view full subset details
example.ExponentiationTest
example.SubTest
```

The test results recorded on GitHub Actions will show:

```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             2 |             2 |              1 |              1 |                 0.0001 |
```

Now, implement the code:

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

You can confirm the both `ExponentiationTest.java` and `MulTest.java` are selected for testing.

Finally, merge PR2 to main to complete this section.

You have learned how to introduce the **subset** command. You can confirm that the new test and its related tests were selected by **launchable subset**.

___

Prev: [Hands-on 2](HANDSON2.md)


