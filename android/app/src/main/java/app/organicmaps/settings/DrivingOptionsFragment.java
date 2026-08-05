package app.organicmaps.settings;

import android.app.Activity;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.widget.SwitchCompat;
import androidx.core.view.ViewCompat;
import app.organicmaps.R;
import app.organicmaps.base.BaseMwmToolbarFragment;
import app.organicmaps.sdk.Router;
import app.organicmaps.sdk.routing.RoutingOptions;
import app.organicmaps.sdk.settings.RoadType;
import app.organicmaps.sdk.util.StringUtils;
import app.organicmaps.util.WindowInsetUtils.PaddingInsetsListener;
import com.google.android.material.slider.Slider;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

public class DrivingOptionsFragment extends BaseMwmToolbarFragment
{
  public static final String BUNDLE_ROAD_TYPES = "road_types";
  private static final String BUNDLE_ROUTE_SPEED = "route_speed";
  private static final String BUNDLE_WIND_ENABLED = "wind_enabled";
  private static final String BUNDLE_WIND_SPEED = "wind_speed";
  private static final String BUNDLE_WIND_DIRECTION = "wind_direction";
  @StringRes
  private static final int[] WIND_DIRECTION_LABELS = {
      R.string.route_wind_direction_n,  R.string.route_wind_direction_ne, R.string.route_wind_direction_e,
      R.string.route_wind_direction_se, R.string.route_wind_direction_s,  R.string.route_wind_direction_sw,
      R.string.route_wind_direction_w,  R.string.route_wind_direction_nw};
  @NonNull
  private Set<RoadType> mRoadTypes = Collections.emptySet();
  private View mContent;
  private boolean mRouteSpeedSupported;
  private int mInitialRouteSpeedPercentage;
  private int mRouteSpeedPercentage;
  private boolean mWindSupported;
  private boolean mInitialWindEnabled;
  private boolean mWindEnabled;
  private int mInitialWindSpeedKmph;
  private int mWindSpeedKmph;
  private int mInitialWindDirectionDegrees;
  private int mWindDirectionDegrees;

  @Nullable
  @Override
  public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                           @Nullable Bundle savedInstanceState)
  {
    View root = inflater.inflate(R.layout.fragment_driving_options, container, false);
    mRouteSpeedSupported = Router.isRouteSpeedSettingSupported();
    mInitialRouteSpeedPercentage =
        mRouteSpeedSupported ? Router.getRouteSpeedPercentage() : Router.DEFAULT_ROUTE_SPEED_PERCENTAGE;
    mRouteSpeedPercentage = savedInstanceState != null
                              ? savedInstanceState.getInt(BUNDLE_ROUTE_SPEED, mInitialRouteSpeedPercentage)
                              : mInitialRouteSpeedPercentage;
    mWindSupported = Router.isBicycleWindSettingSupported();
    mInitialWindEnabled = mWindSupported && Router.isBicycleWindEnabled();
    mInitialWindSpeedKmph = mWindSupported ? Router.getBicycleWindSpeedKmph() : Router.DEFAULT_WIND_SPEED_KMPH;
    mInitialWindDirectionDegrees = mWindSupported ? Router.getBicycleWindDirectionDegrees() : 0;
    mWindEnabled = savedInstanceState != null ? savedInstanceState.getBoolean(BUNDLE_WIND_ENABLED, mInitialWindEnabled)
                                              : mInitialWindEnabled;
    mWindSpeedKmph = savedInstanceState != null ? savedInstanceState.getInt(BUNDLE_WIND_SPEED, mInitialWindSpeedKmph)
                                                : mInitialWindSpeedKmph;
    mWindDirectionDegrees = savedInstanceState != null
                              ? savedInstanceState.getInt(BUNDLE_WIND_DIRECTION, mInitialWindDirectionDegrees)
                              : mInitialWindDirectionDegrees;
    initViews(root);
    ViewCompat.setOnApplyWindowInsetsListener(mContent, new PaddingInsetsListener(false, true, true, true));
    mRoadTypes = savedInstanceState != null && savedInstanceState.containsKey(BUNDLE_ROAD_TYPES)
                   ? makeRouteTypes(savedInstanceState)
                   : RoutingOptions.getActiveRoadTypes();
    return root;
  }

  @NonNull
  private Set<RoadType> makeRouteTypes(@NonNull Bundle bundle)
  {
    Set<RoadType> result = new HashSet<>();
    List<Integer> items = Objects.requireNonNull(bundle.getIntegerArrayList(BUNDLE_ROAD_TYPES));
    for (Integer each : items)
    {
      result.add(RoadType.values()[each]);
    }
    return result;
  }

  @Override
  public void onSaveInstanceState(@NonNull Bundle outState)
  {
    super.onSaveInstanceState(outState);
    ArrayList<Integer> savedRoadTypes = new ArrayList<>();
    for (RoadType each : mRoadTypes)
    {
      savedRoadTypes.add(each.ordinal());
    }
    outState.putIntegerArrayList(BUNDLE_ROAD_TYPES, savedRoadTypes);
    outState.putInt(BUNDLE_ROUTE_SPEED, mRouteSpeedPercentage);
    outState.putBoolean(BUNDLE_WIND_ENABLED, mWindEnabled);
    outState.putInt(BUNDLE_WIND_SPEED, mWindSpeedKmph);
    outState.putInt(BUNDLE_WIND_DIRECTION, mWindDirectionDegrees);
  }

  private boolean areSettingsNotChanged()
  {
    if (mRouteSpeedSupported)
    {
      boolean speedUnchanged = mInitialRouteSpeedPercentage == mRouteSpeedPercentage;
      boolean windUnchanged = !mWindSupported
                           || (mInitialWindEnabled == mWindEnabled && mInitialWindSpeedKmph == mWindSpeedKmph
                               && mInitialWindDirectionDegrees == mWindDirectionDegrees);
      return speedUnchanged && windUnchanged;
    }

    Set<RoadType> lastActiveRoadTypes = RoutingOptions.getActiveRoadTypes();
    return mRoadTypes.equals(lastActiveRoadTypes);
  }

  @Override
  public boolean onBackPressed()
  {
    if (areSettingsNotChanged())
    {
      requireActivity().setResult(Activity.RESULT_CANCELED);
    }
    else
    {
      if (mWindSupported)
        Router.setBicycleRouteSettings(mRouteSpeedPercentage, mWindEnabled, mWindSpeedKmph, mWindDirectionDegrees);
      else if (mRouteSpeedSupported)
        Router.setRouteSpeedPercentage(mRouteSpeedPercentage);
      requireActivity().setResult(Activity.RESULT_OK);
    }

    return super.onBackPressed();
  }

  private void initViews(@NonNull View root)
  {
    mContent = root.findViewById(R.id.content);
    root.findViewById(R.id.car_options).setVisibility(mRouteSpeedSupported ? View.GONE : View.VISIBLE);

    View routeSpeedOptions = root.findViewById(R.id.route_speed_options);
    routeSpeedOptions.setVisibility(mRouteSpeedSupported ? View.VISIBLE : View.GONE);
    if (mRouteSpeedSupported)
    {
      TextView routeSpeedValue = root.findViewById(R.id.route_speed_value);
      Slider routeSpeedSlider = root.findViewById(R.id.route_speed_slider);
      routeSpeedSlider.setValue(mRouteSpeedPercentage);
      routeSpeedValue.setText(formatPercentage(mRouteSpeedPercentage));
      routeSpeedSlider.addOnChangeListener((slider, value, fromUser) -> {
        mRouteSpeedPercentage = Math.round(value);
        routeSpeedValue.setText(formatPercentage(mRouteSpeedPercentage));
      });
    }

    View windOptions = root.findViewById(R.id.route_wind_options);
    windOptions.setVisibility(mWindSupported ? View.VISIBLE : View.GONE);
    if (mWindSupported)
    {
      SwitchCompat windEnabled = root.findViewById(R.id.route_wind_enabled);
      View windInputs = root.findViewById(R.id.route_wind_inputs);
      TextView windSpeedValue = root.findViewById(R.id.route_wind_speed_value);
      Slider windSpeedSlider = root.findViewById(R.id.route_wind_speed_slider);
      TextView windDirectionValue = root.findViewById(R.id.route_wind_direction_value);
      Slider windDirectionSlider = root.findViewById(R.id.route_wind_direction_slider);

      windEnabled.setChecked(mWindEnabled);
      windInputs.setVisibility(mWindEnabled ? View.VISIBLE : View.GONE);
      windSpeedSlider.setValue(mWindSpeedKmph);
      windSpeedValue.setText(formatWindSpeed(mWindSpeedKmph));
      windDirectionSlider.setValue(mWindDirectionDegrees);
      windDirectionValue.setText(formatWindDirection(mWindDirectionDegrees));

      windEnabled.setOnCheckedChangeListener((button, isChecked) -> {
        mWindEnabled = isChecked;
        windInputs.setVisibility(isChecked ? View.VISIBLE : View.GONE);
      });
      windSpeedSlider.addOnChangeListener((slider, value, fromUser) -> {
        mWindSpeedKmph = Math.round(value);
        windSpeedValue.setText(formatWindSpeed(mWindSpeedKmph));
      });
      windDirectionSlider.addOnChangeListener((slider, value, fromUser) -> {
        mWindDirectionDegrees = Math.round(value);
        windDirectionValue.setText(formatWindDirection(mWindDirectionDegrees));
      });
    }

    SwitchCompat tollsBtn = root.findViewById(R.id.avoid_tolls_btn);
    tollsBtn.setChecked(RoutingOptions.hasOption(RoadType.Toll));
    CompoundButton.OnCheckedChangeListener tollBtnListener = new ToggleRoutingOptionListener(RoadType.Toll);
    tollsBtn.setOnCheckedChangeListener(tollBtnListener);

    SwitchCompat motorwaysBtn = root.findViewById(R.id.avoid_motorways_btn);
    motorwaysBtn.setChecked(RoutingOptions.hasOption(RoadType.Motorway));
    CompoundButton.OnCheckedChangeListener motorwayBtnListener = new ToggleRoutingOptionListener(RoadType.Motorway);
    motorwaysBtn.setOnCheckedChangeListener(motorwayBtnListener);

    SwitchCompat ferriesBtn = root.findViewById(R.id.avoid_ferries_btn);
    ferriesBtn.setChecked(RoutingOptions.hasOption(RoadType.Ferry));
    CompoundButton.OnCheckedChangeListener ferryBtnListener = new ToggleRoutingOptionListener(RoadType.Ferry);
    ferriesBtn.setOnCheckedChangeListener(ferryBtnListener);

    SwitchCompat dirtyRoadsBtn = root.findViewById(R.id.avoid_dirty_roads_btn);
    dirtyRoadsBtn.setChecked(RoutingOptions.hasOption(RoadType.Dirty));
    CompoundButton.OnCheckedChangeListener dirtyBtnListener = new ToggleRoutingOptionListener(RoadType.Dirty);
    dirtyRoadsBtn.setOnCheckedChangeListener(dirtyBtnListener);
  }

  @NonNull
  private static String formatPercentage(int percentage)
  {
    return NumberFormat.getPercentInstance().format(percentage / 100.0);
  }

  @NonNull
  private static String formatWindSpeed(int speedKmph)
  {
    Pair<String, String> speedAndUnits = StringUtils.nativeFormatSpeedAndUnits(speedKmph / 3.6);
    return speedAndUnits.first + "\u00a0" + speedAndUnits.second;
  }

  @NonNull
  private String formatWindDirection(int directionDegrees)
  {
    int labelIndex = directionDegrees / Router.WIND_DIRECTION_STEP_DEGREES;
    return getString(WIND_DIRECTION_LABELS[labelIndex]) + " · " + directionDegrees + "°";
  }

  private static class ToggleRoutingOptionListener implements CompoundButton.OnCheckedChangeListener
  {
    @NonNull
    private final RoadType mRoadType;

    private ToggleRoutingOptionListener(@NonNull RoadType roadType)
    {
      mRoadType = roadType;
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked)
    {
      if (isChecked)
        RoutingOptions.addOption(mRoadType);
      else
        RoutingOptions.removeOption(mRoadType);
    }
  }
}
