import 'package:actual/common/const/data.dart';
import 'package:actual/retaurant/component/restaurant_card.dart';
import 'package:actual/retaurant/model/restaurant_model.dart';
import 'package:actual/retaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaurant() async {
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get(
        'http://$realIp/restaurant',
        options: Options(
            headers: {
              'authorization': 'Bearer $accessToken',
            }
        )
    );

    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List>(
            future: paginateRestaurant(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  final parseItem = RestaurantModel.fromJson(json: item);

                  return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => RestaurantDetailScreen(id: parseItem.id)));
                      },
                      child: RestaurantCard.fromModel(model: parseItem),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
