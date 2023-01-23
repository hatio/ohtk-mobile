part of 'widgets.dart';

class ValidationWrapper extends StatefulWidget {
  final opsv.Field field;
  final Widget child;

  const ValidationWrapper(this.field, {Key? key, required this.child})
      : super(key: key);

  @override
  State<ValidationWrapper> createState() => _ValidationWrapperState();
}

class _ValidationWrapperState extends State<ValidationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: (widget.field.isValid == false)
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(100, 100, 100, 0.7),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.child,
                const SizedBox(height: 8),
                if (widget.field.invalidMessage != "")
                  Text(widget.field.invalidMessage ?? "",
                      style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
