import 'package:objd/basic/types/condition.dart';
import 'package:objd/basic/types/entity.dart';
import 'package:objd/basic/widgets.dart';
import 'package:objd/wrappers/comment.dart';
import 'package:objd/basic/group.dart';
import 'package:objd/basic/for_list.dart';
import 'package:meta/meta.dart';
import 'package:objd/basic/widget.dart';
import 'package:objd/build/build.dart';

class If extends RestActionAble {
  List<List<dynamic>> conds;
  List<Widget> then;
  List<Widget> orElse;
  If elseWidget;
  bool invert = false;
  Entity assignTag;
  bool encapsulate;

  String targetFilePath;
  String targetFileName;
  Predicate predicate;

  /// The if widget accepts a Condition and runs the children if the condition is true.
  ///
  ///If just gives you an execute wrapper with if and else statements. The conditions have their own class.
  ///**Example:**
  /// ```dart
  /// If(
  /// 	Condition(Entity.Player()),
  /// 	Then: [
  /// 		Say(msg:'true')
  /// 	],
  /// 	Else: [
  /// 		Say(msg:'false')
  /// 	]
  /// )
  /// ```
  If(
    dynamic condition, {
    @required this.then,
    this.orElse,
    this.targetFilePath = 'objd',
    this.targetFileName,
    this.encapsulate = true,
    this.assignTag,
  }) {
    assert(then != null);
    getCondition(condition);
  }

  /// You can negate the Condition with `If.not`:
  /// ```dart
  /// If.not(
  /// 	Condition(Entity.Player()),
  /// 	Then: [
  /// 		Say(msg:'true')
  /// 	]
  /// )
  /// ```
  If.not(
    dynamic condition, {
    @required this.then,
    this.orElse,
    this.targetFilePath = 'objd',
    this.targetFileName,
    this.encapsulate = true,
    this.assignTag,
  }) {
    assert(then != null);
    assert(then.isNotEmpty);
    invert = true;
    getCondition(condition);
  }
  void getCondition(dynamic condition) {
    if (condition is Predicate) predicate = condition;
    if (condition is Condition) {
      conds = condition.getList();
    } else {
      conds = Condition(condition).getList();
    }
  }

  @override
  Widget generate(Context context) {
    var prefixes = Condition.getPrefixes(conds, invert);

    var children = <Widget>[];
    // group into seperate file(and get if id)
    if (orElse != null || prefixes.length >= 2 || assignTag != null) {
      assignTag ??= Entity.Player();
      if (then.length > 2 && context.file.isNotEmpty) {
        then.insert(0, Comment('If statement from file: ' + context.file));
      }

      if (orElse != null && orElse.length > 2 && context.file.isNotEmpty) {
        orElse.insert(0, Comment('Else statement from file: ' + context.file));
      }

      children = _getTagVersion(prefixes);
    } else {
      // insert Then inline
      prefixes.forEach((prefix) {
        children.add(Group(
          prefix: 'execute ' + prefix + ' run',
          path: targetFilePath,
          generateIDs: targetFileName == null,
          filename: targetFileName ?? 'if',
          groupMin: encapsulate ? 3 : -1,
          children: then,
        ));
      });
    }
    if (elseWidget != null) children.add(elseWidget);
    if (predicate != null) children.add(predicate);

    return For.of(children);
  }

  List<Widget> _getTagVersion(List<String> prefixes) {
    var children = <Widget>[];
    var id = IndexedFile.getIndexed('if');
    prefixes.forEach((prefix) {
      children.add(
        Group(
          prefix: 'execute ' + prefix + ' run',
          children: [assignTag.addTag('objd_isTrue' + id.toString())],
        ),
      );
    });
    children.add(Group(
      prefix: 'execute as ' +
          assignTag.toString() +
          ' if entity @s[tag=objd_isTrue' +
          id.toString() +
          '] run',
      path: targetFilePath,
      generateIDs: targetFileName == null,
      filename: targetFileName ?? 'if',
      children: then,
    ));
    if (orElse != null) {
      children.add(Group(
        prefix: 'execute as ' +
            assignTag.toString() +
            ' unless entity @s[tag=objd_isTrue' +
            id.toString() +
            '] run',
        path: targetFilePath,
        filename: 'else',
        children: orElse,
      ));
    }
    children.add(assignTag.removeTag('objd_isTrue' + id.toString()));
    return children;
  }
}
