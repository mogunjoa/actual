import 'package:actual/retaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository {
  // http://$realIp/restaurant
  factory RestaurantRepository(Dio dio, {required String baseUrl}) =
      _RestaurantRepository;

  // http://$realIp/restaurant/
  // @GET('/')
  // paginate();

  // http://$realIp/restaurant/:id
  @GET('/{id}')
  @Headers({
    'accessToken':'true'
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}
