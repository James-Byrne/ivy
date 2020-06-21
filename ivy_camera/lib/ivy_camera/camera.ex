defmodule IvyCamera.Camera do
  @moduledoc """
  This GenServer creates a stack of images and serves them as requested.

  Configuration
  - delay: The length of time to wait between pushing new frames onto the stack
  """

  use GenServer

  @initial_state %{ frames: [], recording: false, delay: 100 }

  def start_link(), do: start_link([])
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_), do: {:ok, @initial_state}

  @doc "Start recording by adding new frames to the stack"
  def handle_call(:start_recording, _, %{ delay: delay } = state) do
    Process.send_after(self(), :push_frame, delay)
    {:reply, :ok, start_recording(state)}
  end

  @doc "Stop recording, note any existing frames will be removed from the stack"
  def handle_call(:stop_recording, _, state) do
    Kernel.send(self(), :clear_frames)
    {:reply, :ok, stop_recording(state)}
  end

  @doc "Retrieve the next frame from the stack"
  def handle_call({:next_frame, :live}, _, state),
    do: {:reply, {:ok, Picam.next_frame}, state}
  def handle_call(:next_frame, _, state) do
    {status, frame, new_state} = get_next_frame(state)
    {:reply, {status, frame}, new_state}
  end

  #
  # Utiltiy functions
  #

  @doc "Returns if the stream is recording or not"
  def handle_call(:is_recording, _, state), do: {:reply, {:ok, state.recording}, state}

  @doc "Returns if the stream is recording or not"
  def handle_call(:frame_count, _, state), do: {:reply, Kernel.length(state.frames), state}

  @doc "This allows us to adjust the streams delay"
  def handle_call({:set_delay, delay}, _, state), do: {:reply, :ok, set_delay(state, delay)}

  #
  # Implementation
  #

  @doc """
  Clears the stack of all frames & if recording is false sets up hibernate to free memory
  """
  def handle_info(:clear_frames, _, %{ recording: true } = state),
    do: {:reply, :ok, %{ state | frames: [] }}
  def handle_info(:clear_frames, _, state),
    do: {:reply, :ok, %{ state | frames: [] }, :hibernate}

  @doc "Pushes a new frame onto the stack"
  def handle_info(:push_frame, %{ recording: false } = state), do: {:noreply, state}
  def handle_info(:push_frame, %{ delay: delay } = state) do
    Process.send_after(self(), :push_frame, delay)
    {:noreply, push_frame(state)}
  end

  #
  # Functionality
  #

  defp set_delay(state, delay), do: %{ state | delay: delay }

  defp stop_recording(%{ recording: false } = state), do: state
  defp stop_recording(%{ recording: true } = state), do: %{ state | recording: false }

  defp start_recording(%{ recording: true } = state), do: state
  defp start_recording(%{ recording: false } = state), do: %{ state | recording: true }

  defp get_next_frame(%{ recording: false } = state), do: {:error, :not_recording, state}
  defp get_next_frame(%{ frames: [] } = state), do: {:ok, Picam.next_frame, state}
  defp get_next_frame(%{ frames: [h|t] } = state), do: {:ok, h, %{ state | frames: t }}

  defp push_frame(%{ frames: frames } = state), do: %{ state | frames: frames ++ [Picam.next_frame]}
end
