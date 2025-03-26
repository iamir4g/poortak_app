import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/locator.dart';

class SayarehScreen extends StatelessWidget {
  const SayarehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SayarehCubit(sayarehRepository: locator()),
      child: Builder(builder: (context) {
        BlocProvider.of<SayarehCubit>(context).callSayarehDataEvent();
        return BlocBuilder<SayarehCubit, SayarehState>(
            buildWhen: (previous, current) {
          if (previous.sayarehDataStatus == current.sayarehDataStatus) {
            return false;
          }
          return true;
        }, builder: (context, state) {
          /// loading
          if (state.sayarehDataStatus is SayarehDataLoading) {
            return const DotLoadingWidget(size: 100);
          }

          /// completed
          if (state.sayarehDataStatus is SayarehDataCompleted) {
            final SayarehDataCompleted sayarehDataCompleted =
                state.sayarehDataStatus as SayarehDataCompleted;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text("completed"),
                  Text(sayarehDataCompleted.data.sayareh.length.toString()),
                  Text(sayarehDataCompleted.data.sayareh[0].title),
                ],
              ),
            );
          }

          /// error
          if (state.sayarehDataStatus is SayarehDataError) {
            final SayarehDataError sayarehDataError =
                state.sayarehDataStatus as SayarehDataError;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sayarehDataError.errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800),
                    onPressed: () {
                      /// call all data again
                      BlocProvider.of<SayarehCubit>(context)
                          .callSayarehDataEvent();
                    },
                    child: const Text("تلاش دوباره"),
                  )
                ],
              ),
            );
          }
          return Container();
        });
      }),
    );
  }
}
